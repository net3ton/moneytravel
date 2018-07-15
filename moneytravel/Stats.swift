//
//  Stats.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appStats = AppStats()

class AppStats {

    init() {
    }

    public func getSumSince(date: Date) -> (sum: Float, days: Int) {
        let context = get_context()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        let daysCount = Calendar.current.dateComponents([.day], from: date, to: Date()).day! + 1
        var sum: Float = 0.0

        do {
            fetchRequest.predicate = NSPredicate(format: "date >= %@", date as NSDate)
            let spends = try context.fetch(fetchRequest)

            for sinfo in spends {
                if sinfo.bcurrency == appSettings.currencyBase {
                    sum += sinfo.bsum
                }
            }
        }
        catch let error {
            print("Failed to fetch spends for stats! ERROR: " + error.localizedDescription)
        }

        return (sum: sum, days: max(1, daysCount))
    }
}

