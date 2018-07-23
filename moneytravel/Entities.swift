//
//  Entities.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
    static let helper = CodingUserInfoKey(rawValue: "helper")!
}

class DecoderHepler {
    private var categories: [CategoryModel] = []

    public func addCategory(cat: CategoryModel) {
        categories.append(cat)
    }

    public func getCategory(by uid: String) -> CategoryModel? {
        for cat in categories {
            if cat.uid == uid {
                return cat
            }
        }
        
        return nil
    }
}


@objc(CategoryModel)
public class CategoryModel: NSManagedObject, Codable {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case iconname = "icon"
        case colorvalue = "color"
        case position = "pos"
        case removed = "rem"
    }
    
    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let helper = decoder.userInfo[.helper] as? DecoderHepler  else { fatalError() }
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Category", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try values.decode(String.self, forKey: .uid)
        self.name = try values.decode(String.self, forKey: .name)
        self.iconname = try values.decode(String.self, forKey: .iconname)
        self.colorvalue = try values.decode(Int32.self, forKey: .colorvalue)
        self.position = try values.decode(Int16.self, forKey: .position)
        self.removed = try values.decode(Bool.self, forKey: .removed)

        helper.addCategory(cat: self)
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
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
        case uid
        case name
        case date
        case colorvalue = "color"
        case comment = "comm"
        case removed = "rem"
    }
    
    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Mark", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try values.decode(String.self, forKey: .uid)
        self.name = try values.decode(String.self, forKey: .name)
        self.date = try values.decode(Date.self, forKey: .date)
        self.colorvalue = try values.decode(Int32.self, forKey: .colorvalue)
        self.comment = try values.decode(String.self, forKey: .comment)
        self.removed = try values.decode(Bool.self, forKey: .removed)
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.colorvalue, forKey: .colorvalue)
        try container.encode(self.comment, forKey: .comment)
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
        case uid
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
        guard let helper = decoder.userInfo[.helper] as? DecoderHepler  else { fatalError() }
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Spend", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try values.decode(String.self, forKey: .uid)
        self.date = try values.decode(Date.self, forKey: .date)
        self.sum = try values.decode(Float.self, forKey: .sum)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.bsum = try values.decode(Float.self, forKey: .bsum)
        self.bcurrency = try values.decode(String.self, forKey: .bcurrency)
        self.comment = try values.decode(String.self, forKey: .comment)
        self.removed = try values.decode(Bool.self, forKey: .removed)
        
        let catUid = try values.decode(String.self, forKey: .category)
        self.category = helper.getCategory(by: catUid)
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.sum, forKey: .sum)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.bsum, forKey: .bsum)
        try container.encode(self.bcurrency, forKey: .bcurrency)
        try container.encode(self.comment, forKey: .comment)
        try container.encode(self.removed, forKey: .removed)
        
        try container.encode(self.category?.uid, forKey: .category)
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
