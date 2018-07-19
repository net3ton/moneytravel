//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

func num_to_string(sum: Float) -> String {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "\u{00a0}" // non-breaking space
    formatter.groupingSize = 3
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.minimumIntegerDigits = 1

    return formatter.string(from: NSNumber(value: sum)) ?? "0.00"
}

func sum_to_string(sum: Float, currency: String) -> String {
    return String.init(format: "%@ %@", num_to_string(sum: sum), currency)
}

func get_delegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func get_context() -> NSManagedObjectContext {
    return get_delegate().persistentContainer.viewContext
}

func top_view_controller(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return top_view_controller(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return top_view_controller(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return top_view_controller(controller: presented)
    }
    return controller
}

private func int32_to_uicolor(_ val: Int32) -> UIColor {
    let r: CGFloat = CGFloat(val & 0xFF) / 255.0
    let g: CGFloat = CGFloat(val >> 8 & 0xFF) / 255.0
    let b: CGFloat = CGFloat(val >> 16 & 0xFF) / 255.0
    let a: CGFloat = CGFloat(val >> 24 & 0xFF) / 255.0

    return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
}

private func uicolor_to_int32(_ val: UIColor) -> Int32 {
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    var a: CGFloat = 0
    val.getRed(&r, green: &g, blue: &b, alpha: &a)

    let ir = Int32(r * 255)
    let ig = Int32(g * 255) << 8
    let ib = Int32(b * 255) << 16
    let ia = Int32(a * 255) << 24
    return ia + ib + ig + ir
}


extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}


@objc(CategoryModel)
public class CategoryModel: NSManagedObject, Codable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case iconname = "icon"
        case colorvalue = "color"
        case position = "pos"
        case removed = "rem"
    }

    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Category", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decode(String.self, forKey: .name)
        self.iconname = try values.decode(String.self, forKey: .iconname)
        self.colorvalue = try values.decode(Int32.self, forKey: .colorvalue)
        self.position = try values.decode(Int16.self, forKey: .position)
        self.removed = try values.decode(Bool.self, forKey: .removed)
    }

    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.iconname, forKey: .iconname)
        try container.encode(self.colorvalue, forKey: .colorvalue)
        try container.encode(self.position, forKey: .position)
        try container.encode(self.removed, forKey: .removed)
    }
}

extension CategoryModel {
    var icon: UIImage? {
        return UIImage(named: iconname!)
    }

    var color: UIColor {
        get {
            return int32_to_uicolor(colorvalue)
        }
        set {
            colorvalue = uicolor_to_int32(newValue)
        }
    }
}


@objc(MarkModel)
public class MarkModel: NSManagedObject, Codable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case date
        case colorvalue = "color"
        case removed = "rem"
    }

    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Mark", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try values.decode(String.self, forKey: .name)
        self.date = try values.decode(Date.self, forKey: .date)
        self.colorvalue = try values.decode(Int32.self, forKey: .colorvalue)
        self.removed = try values.decode(Bool.self, forKey: .removed)
    }

    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.name, forKey: .name)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.colorvalue, forKey: .colorvalue)
        try container.encode(self.removed, forKey: .removed)
    }
}

extension MarkModel {
    var color: UIColor {
        get {
            return int32_to_uicolor(colorvalue)
        }
        set {
            colorvalue = uicolor_to_int32(newValue)
        }
    }
}


@objc(SpendModel)
public class SpendModel: NSManagedObject, Codable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    enum CodingKeys: String, CodingKey {
        case date
        case category = "cat"
        case sum
        case currency = "iso"
        case bsum
        case bcurrency = "biso"
        case comment = "comm"
        case removed = "rem"
    }

    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Spend", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.date = try values.decode(Date.self, forKey: .date)
        self.sum = try values.decode(Float.self, forKey: .sum)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.bsum = try values.decode(Float.self, forKey: .bsum)
        self.bcurrency = try values.decode(String.self, forKey: .bcurrency)
        self.comment = try values.decode(String.self, forKey: .comment)
        self.removed = try values.decode(Bool.self, forKey: .removed)
        
        let catPosition = try values.decode(Int16.self, forKey: .category)
        self.category = appCategories.getByPosition(catPosition)
    }

    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.date, forKey: .date)
        try container.encode(self.category?.position, forKey: .category)
        try container.encode(self.sum, forKey: .sum)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.bsum, forKey: .bsum)
        try container.encode(self.bcurrency, forKey: .bcurrency)
        try container.encode(self.comment, forKey: .comment)
        try container.encode(self.removed, forKey: .removed)
    }
}

extension SpendModel {
    public func getSumString() -> String {
        return sum_to_string(sum: sum, currency: currency!)
    }

    public func getBaseSumString() -> String {
        return sum_to_string(sum: bsum, currency: bcurrency!)
    }
}


class AppData: Codable {
    private var baseVer: Int32 = 0
    private var baseId: String = ""

    private var categories: [CategoryModel] = []
    private var timestamps: [MarkModel] = []
    private var spends: [SpendModel] = []

    init() {
        initData()
    }

    private func reset() {
        baseVer = 1
        baseId = UUID().uuidString
    }

    public func initData() {
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
            print("Failed to init data! ERROR: " + error.localizedDescription)
        }
    }

    public func fetchAllData() {
        categories = appCategories.fetchAll()
        timestamps = appTimestamps.fetchAll()
        spends = appSpends.fetchAll()
    }

    public func fetchHistory(_ history: [DaySpends]) {
        for daily in history {
            spends.append(contentsOf: daily.spends)

            for spend in daily.spends {
                if let cat = spend.category, !categories.contains(cat) {
                    categories.append(cat)
                }
            }
        }
    }

    static public func load(from data: Data) -> AppData? {
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

    static public func getExportName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }

    public func exportToData(name: String) {
        do {
            let plistEncoder = PropertyListEncoder()
            plistEncoder.outputFormat = .binary

            let plistData = try plistEncoder.encode(self)

            let docsPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportPath = docsPath.appendingPathComponent(String(format: "%@.data", name))

            try plistData.write(to: exportPath)
        }
        catch let error {
            print("Failed to export! ERROR: " + error.localizedDescription)
        }
    }

    public func exportToJSON(name: String) {
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
            print("Failed to export! ERROR: " + error.localizedDescription)
        }
    }
}
