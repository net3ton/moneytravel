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
        case version = "ver"
        case removed = "rem"
    }
    
    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Category", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.uid = try values.decode(String.self, forKey: .uid)
        self.name = try values.decode(String.self, forKey: .name)
        self.iconname = try values.decode(String.self, forKey: .iconname)
        self.colorvalue = try values.decode(Int32.self, forKey: .colorvalue)
        self.position = try values.decode(Int16.self, forKey: .position)
        
        if let version = try values.decodeIfPresent(Int16.self, forKey: .version) {
            self.version = version
        }
        
        if let removed = try values.decodeIfPresent(Bool.self, forKey: .removed) {
            self.removed = removed
        }
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.iconname, forKey: .iconname)
        try container.encode(self.colorvalue, forKey: .colorvalue)
        try container.encode(self.position, forKey: .position)

        if self.version > 0 {
            try container.encode(self.version, forKey: .version)
        }

        if self.removed {
            try container.encode(self.removed, forKey: .removed)
        }
    }
}

extension CategoryModel {
    var icon: UIImage? {
        if let iconn = iconname {
            return UIImage(named: iconn)
        }
        return nil
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
        case version = "ver"
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
        
        if let comment = try values.decodeIfPresent(String.self, forKey: .comment) {
            self.comment = comment
        }

        if let version = try values.decodeIfPresent(Int16.self, forKey: .version) {
            self.version = version
        }
        
        if let removed = try values.decodeIfPresent(Bool.self, forKey: .removed) {
            self.removed = removed
        }
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.colorvalue, forKey: .colorvalue)
        
        if let comment = self.comment, !comment.isEmpty {
            try container.encode(comment, forKey: .comment)
        }

        if self.version > 0 {
            try container.encode(self.version, forKey: .version)
        }
        
        if self.removed {
            try container.encode(self.removed, forKey: .removed)
        }
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
        case version = "ver"
        case removed = "rem"
    }
    
    // Decodable
    public required init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Spend", in: context) else { fatalError() }
        super.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uid = try values.decode(String.self, forKey: .uid)
        self.date = try values.decode(Date.self, forKey: .date)
        self.catid = try values.decode(String.self, forKey: .category)
        self.sum = try values.decode(Float.self, forKey: .sum)
        self.currency = try values.decode(String.self, forKey: .currency)
        self.bsum = try values.decode(Float.self, forKey: .bsum)
        self.bcurrency = try values.decode(String.self, forKey: .bcurrency)

        if let comment = try values.decodeIfPresent(String.self, forKey: .comment) {
            self.comment = comment
        }

        if let version = try values.decodeIfPresent(Int16.self, forKey: .version) {
            self.version = version
        }

        if let removed = try values.decodeIfPresent(Bool.self, forKey: .removed) {
            self.removed = removed
        }
    }
    
    // Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.uid, forKey: .uid)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.catid, forKey: .category)
        try container.encode(self.sum, forKey: .sum)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.bsum, forKey: .bsum)
        try container.encode(self.bcurrency, forKey: .bcurrency)

        if let comment = self.comment, !comment.isEmpty {
            try container.encode(comment, forKey: .comment)
        }

        if self.version > 0 {
            try container.encode(self.version, forKey: .version)
        }

        if self.removed {
            try container.encode(self.removed, forKey: .removed)
        }
    }
}

extension SpendModel {
    var category: CategoryModel? {
        return appCategories.getCategory(by: catid!)
    }

    public func getSumString() -> String {
        return sum_to_string(sum: sum, currency: currency!)
    }
    
    public func getBaseSumString() -> String {
        return sum_to_string(sum: bsum, currency: bcurrency!)
    }
}
