//
//  Data.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appInfo = AppInfo()

class AppInfo {
    private(set) var baseVer: Int32 = 0
    private(set) var baseId: String = ""

    init() {
        initData()
    }

    private func reset() {
        baseVer = 1
        baseId = UUID().uuidString
    }

    private func initData() {
        let context = get_context()
        let infoEntity = NSEntityDescription.entity(forEntityName: "Info", in: context)
        let fetchRequest = NSFetchRequest<InfoModel>(entityName: "Info")
        
        do {
            let infos = try context.fetch(fetchRequest)
            if infos.isEmpty {
                let info = InfoModel(entity: infoEntity!, insertInto: context)
                
                reset()
                info.id = baseId
                info.version = baseVer
                try context.save()
            }
            else {
                baseId = infos[0].id!
                baseVer = infos[0].version
            }
        }
        catch let error {
            print("Failed to init application info! ERROR: " + error.localizedDescription)
        }
    }
}


class AppData: Codable {
    private(set) var baseVer: Int32
    private(set) var baseId: String

    private(set) var categories: [CategoryModel]
    private(set) var timestamps: [MarkModel]
    private(set) var spends: [SpendModel]

    init() {
        baseVer = appInfo.baseVer
        baseId = appInfo.baseId

        categories = appCategories.fetchAll(removed: true)
        timestamps = appTimestamps.fetchAll(removed: true)
        spends = appSpends.fetchAll(removed: true)
    }

    init(history: [DaySpends]) {
        baseVer = appInfo.baseVer
        baseId = appInfo.baseId

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

    static public func loadFromData(_ data: Data) -> AppData? {
        let plistDecoder = PropertyListDecoder()
        plistDecoder.userInfo[.context] = get_context()

        do {
            return try plistDecoder.decode(AppData.self, from: data)
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
        }

        return nil
    }

    public func exportToData() -> Data? {
        do {
            let plistEncoder = PropertyListEncoder()
            plistEncoder.outputFormat = .binary

            return try plistEncoder.encode(self)
        }
        catch let error {
            print("Failed to export! ERROR: " + error.localizedDescription)
        }

        return nil
    }

    public func saveToJSON(name: String) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted

            let jsonData = try jsonEncoder.encode(self)
            
            let docsPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportPath = docsPath.appendingPathComponent(String(format: "%@.json", name))
            
            try jsonData.write(to: exportPath)
        }
        catch let error {
            print("Failed to export to JSON! ERROR: " + error.localizedDescription)
        }
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
            line.append(String(format: "%0.03f", spend.sum))
            line.append(spend.currency!)
            line.append(String(format: "%0.03f", spend.bsum))
            line.append(spend.category!.name!)
            line.append(spend.comment!)

            if let lineData = prepareCSVLine(values: line, sep: SEP) {
                data.append(lineData)
            }
        }

        return data
    }
    
    public func saveToCSV(name: String) {
        do {
            let docsPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportPath = docsPath.appendingPathComponent(String(format: "%@.csv", name))
            
            try exportToCSV().write(to: exportPath)
        }
        catch let error {
            print("Failed to export to CVS! ERROR: " + error.localizedDescription)
        }
    }
}
