//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

extension CategoryModel {
    var icon: UIImage? {
        return UIImage(named: iconname!)
    }
}

var appSpends: [SpendModel]?
var appCategories: [CategoryModel]?

func getSpendsCount() -> Int {
    guard let spends = appSpends else {
        return 0
    }

    return spends.count
}

func getCategoriesCount() -> Int {
    guard let cats = appCategories else {
        return 0
    }

    return cats.count
}

//let DAYS_HISTORY = 3
//var appSpendsN: [[SpendModel]?] = [[SpendModel]?]()

/*
class SpendModel: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var comment: String

    @NSManaged var sum: Float
    @NSManaged var currency: String
    @NSManaged var bsum: Float
    @NSManaged var bcurrency: String
}

struct SpendInfo {
    var id: Int
    var catId: Int
    //var date: Date
    var comment: String

    var sum: Double
    var currency: String

    //var bsum: Double
    //var bcurrency: String
}
*/
