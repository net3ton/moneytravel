//
//  Data.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData
import DataCompression

class AppData: Codable {
    private static var VER: Int32 = 1
    
    private(set) var baseVer: Int32

    private(set) var categories: [CategoryModel]
    private(set) var timestamps: [MarkModel]
    private(set) var spends: [SpendModel]

    init(fetchRemoved: Bool = true, with context: NSManagedObjectContext = get_context()) {
        baseVer = AppData.VER

        categories = appCategories.fetchAll(removed: fetchRemoved, with: context)
        timestamps = appTimestamps.fetchAll(removed: fetchRemoved, with: context)
        spends = appSpends.fetchAll(removed: fetchRemoved, with: context)
    }

    init(history: [DaySpends]) {
        baseVer = AppData.VER

        categories = []
        timestamps = []
        spends = []

        for daily in history {
            spends.append(contentsOf: daily.spends)
            timestamps.append(contentsOf: daily.tmarks)
            
            /// FIX
            for spend in daily.spends {
                if let cat = spend.category, !categories.contains(cat) {
                    categories.append(cat)
                }
            }
        }
    }

    public func importData(with context: NSManagedObjectContext) {
        print(String(format: "[Import] data (%i, %i, %i)", categories.count, spends.count, timestamps.count))
        
        context.mergePolicy = NSOverwriteMergePolicy
        
        var tstampCount = 0
        var catCount = 0
        var spendCount = 0
        
        for tstamp in timestamps {
            if appTStampChecker.shouldUpdate(uid: tstamp.uid!, ver: tstamp.version, with: context) {
                context.insert(tstamp)
                tstampCount += 1
            }
        }
        for cat in categories {
            if appCategoryChecker.shouldUpdate(uid: cat.uid!, ver: cat.version, with: context) {
                context.insert(cat)
                catCount += 1
            }
        }
        for spend in spends {
            if appSpendChecker.shouldUpdate(uid: spend.uid!, ver: spend.version, with: context) {
                context.insert(spend)
                spendCount += 1
            }
        }
        
        do {
            if catCount > 0 || spendCount > 0 || tstampCount > 0 {
                try context.save()
            }
            
            print(String(format: "[Import] saved (%i, %i, %i)", catCount, spendCount, tstampCount))
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
        }
    }
    
    static public func loadFromData(_ rawdata: Data) -> AppData? {
        guard let data = rawdata.gunzip() else {
            print("Failed to import! Failed to unzip data!")
            return nil
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            return try jsonDecoder.decode(AppData.self, from: data)
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
        }
        
        return nil
    }
    
    public func exportToData() -> Data? {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted
            
            return try jsonEncoder.encode(self).gzip()
        }
        catch let error {
            print("Failed to export! ERROR: " + error.localizedDescription)
        }

        return nil
    }
    
    static public func getDataHash(_ gzip: Data) -> String {
        let ui64data = gzip.subdata(in: (gzip.count-8)..<gzip.count)
        return ui64data.map {
            String(format: "%02X", $0)
            }.joined()
    }
    
    private func prepareCSVLine(values: [String], sep: String) -> Data? {
        var line = ""
        
        for (ind, val) in values.enumerated() {
            line += val
            
            if ind == values.count - 1 {
                line += "\n"
            }
            else {
                line += sep
            }
        }

        return line.data(using: .utf8)
    }
    
    public func exportToCSV() -> Data {
        let SEP = ","
        var data = Data()
        
        let header = ["Date", "Time", "Sum", "Currency", appSettings.currencyBase, "Category", "Comment"]
        if let headerData = prepareCSVLine(values: header, sep: SEP) {
            data.append(headerData)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for spend in spends {
            var line: [String] = []

            line.append(dateFormatter.string(from: spend.date!))
            line.append(timeFormatter.string(from: spend.date!))
            line.append(String(format: "%0.02f", spend.sum))
            line.append(spend.currency!)
            line.append(String(format: "%0.05f", spend.bsum))
            line.append(spend.category!.name!)
            line.append(spend.comment ?? "")

            if let lineData = prepareCSVLine(values: line, sep: SEP) {
                data.append(lineData)
            }
        }

        return data
    }
}
