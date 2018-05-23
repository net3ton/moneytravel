//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

struct SpendCategory {
    var id: Int
    var icon: UIImage
    var name: String
}

let categories: [SpendCategory] = [
    SpendCategory(id: 0, icon: UIImage(named: "Food")!, name: "food"),
    SpendCategory(id: 1, icon: UIImage(named: "House")!, name: "rent"),
    SpendCategory(id: 2, icon: UIImage(named: "Cafe")!, name: "cafe"),
    SpendCategory(id: 3, icon: UIImage(named: "Games")!, name: "games"),
    SpendCategory(id: 4, icon: UIImage(named: "Gift")!, name: "gifts"),
    SpendCategory(id: 5, icon: UIImage(named: "Museum")!, name: "museums"),
    SpendCategory(id: 6, icon: UIImage(named: "Transport")!, name: "transport"),
    SpendCategory(id: 7, icon: UIImage(named: "Restaurant")!, name: "restaurant"),
    SpendCategory(id: 7, icon: UIImage(named: "Canteen")!, name: "canteen"),
    SpendCategory(id: 7, icon: UIImage(named: "Clothes")!, name: "clothes"),
    SpendCategory(id: 7, icon: UIImage(named: "Entertain")!, name: "entertain")
]

func getCategory(id: Int) -> SpendCategory? {
    for cat in categories {
        if cat.id == id {
            return cat
        }
    }
    
    return nil
}

func getIcon(forCategory id: Int) -> UIImage? {
    return getCategory(id: id)?.icon
}

func getName(forCategory id: Int) -> String? {
    return getCategory(id: id)?.name
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

var spends: [SpendInfo] = [
    SpendInfo(id: 0, catId: 0, comment: "some", sum: 11.2, currency: "RUB"),
    SpendInfo(id: 1, catId: 0, comment: "", sum: 202.2, currency: "RUB"),
    SpendInfo(id: 1, catId: 0, comment: "", sum: 202.2, currency: "RUB"),
    SpendInfo(id: 1, catId: 0, comment: "", sum: 202.2, currency: "RUB"),
    SpendInfo(id: 1, catId: 0, comment: "", sum: 202.2, currency: "RUB"),
    SpendInfo(id: 1, catId: 0, comment: "", sum: 202.2, currency: "RUB")
]
