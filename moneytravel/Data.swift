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

    public func changeBaseId(newId: String) {
        let fetchRequest = NSFetchRequest<InfoModel>(entityName: "Info")
        
        do {
            let infos = try get_context().fetch(fetchRequest)
            if !infos.isEmpty {
                infos[0].id = newId
            }
        }
        catch let error {
            print("Failed to init application info! ERROR: " + error.localizedDescription)
        }
    }
}


enum EExportLocation {
    case sharedFolder
    case icloud
}


class AppData: Codable {
    private(set) var baseVer: Int32
    private(set) var baseId: String

    private(set) var categories: [CategoryModel]
    private(set) var timestamps: [MarkModel]
    private(set) var spends: [SpendModel]

    init(fetchRemoved: Bool = true) {
        baseVer = appInfo.baseVer
        baseId = appInfo.baseId

        categories = appCategories.fetchAll(removed: fetchRemoved)
        timestamps = appTimestamps.fetchAll(removed: fetchRemoved)
        spends = appSpends.fetchAll(removed: fetchRemoved)
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

    public func importData() {
        print("[Import] base: " + baseId)
        print(String(format: "[Import] data (%i, %i, %i)", categories.count, spends.count, timestamps.count))
        
        if baseId != appInfo.baseId {
            appInfo.changeBaseId(newId: baseId)
            print("[Import] base id changed")
        }
        
        let context = get_context()
        context.mergePolicy = NSOverwriteMergePolicy
        
        var tstampCount = 0
        var catCount = 0
        var spendCount = 0
        
        for tstamp in timestamps {
            if appTimestamps.shouldUpdate(uid: tstamp.uid!, ver: tstamp.version) {
                context.insert(tstamp)
                tstampCount += 1
            }
        }
        for cat in categories {
            if appCategories.shouldUpdate(uid: cat.uid!, ver: cat.version) {
                context.insert(cat)
                catCount += 1
            }
        }
        for spend in spends {
            if appSpends.shouldUpdate(uid: spend.uid!, ver: spend.version) {
                context.insert(spend)
                spendCount += 1
            }
        }
        
        do {
            try context.save()
            
            print(String(format: "[Import] saved (%i, %i, %i)", catCount, spendCount, tstampCount))
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
        }
    }
    
    static public func getDataHash(_ gzip: Data) -> String {
        let ui64data = gzip.subdata(in: (gzip.count-8)..<gzip.count)
        return ui64data.map {
            String(format: "%02X", $0)
        }.joined()
    }
    
    static public func loadFromData(_ rawdata: Data) -> AppData? {
        guard let data = rawdata.gunzip() else {
            print("Failed to import! Failed to unzip data!")
            return nil
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.userInfo[.context] = get_context()
            
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
    
    public func saveToCSV(name: String, location: EExportLocation) -> Bool {
        guard let path = (location == .icloud) ? appICloudDrive.getDocumentsPath() : getSharedPath() else {
            return false
        }

        do {
            let exportPath = path.appendingPathComponent(name)
            try exportToCSV().write(to: exportPath)
        }
        catch let error {
            print("Failed to export to CVS! ERROR: " + error.localizedDescription)
            return false
        }

        return true
    }
    
    private func getSharedPath() -> URL? {
        return FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
