//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

private func sum_to_string(sum: Float, currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "\u{00a0}" // non-breaking space
    formatter.groupingSize = 3
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.minimumIntegerDigits = 1

    return String.init(format: "%@ %@", formatter.string(from: NSNumber(value: sum))!, currency)
}

extension CategoryModel {
    var icon: UIImage? {
        return UIImage(named: iconname!)
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


var appCategories: [CategoryModel]?

func getCategoriesCount() -> Int {
    guard let cats = appCategories else {
        return 0
    }

    return cats.count
}


let appSpends = AppSpends()

class AppSpends {
    public class DaySpends {
        public var date: Date
        public var spends: [SpendModel] = []

        init(forDate: Date) {
            date = forDate
        }

        public func getInfoString() -> String {
            var sum: Float = 0
            var bsum: Float = 0

            for spend in spends {
                if spend.currency == appSettings.currency {
                    sum += spend.sum
                }
                if spend.bcurrency == appSettings.currencyBase {
                    bsum += spend.bsum
                }
            }

            let bsumStr = sum_to_string(sum: bsum, currency: appSettings.currencyBase)
            let sumStr = sum_to_string(sum: sum, currency: appSettings.currency)

            return String.init(format: "%@: %@ (%@)", getDateString(), bsumStr, sumStr)
        }

        public func getRemainString() -> String {
            
            return ""
        }

        public func getDateString() -> String {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            if date == today {
                return "Today"
            }
            
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            if date == yesterday {
                return "Yesterday"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd LLLL"
            return formatter.string(from: date)
        }
    }

    private let DAYS_HISTORY = 3
    private(set) var daily: [DaySpends]

    init() {
        daily = [DaySpends]()

        checkDays()
        fetchSpends()
    }

    public func checkDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for i in 0..<DAYS_HISTORY {
            let day = calendar.date(byAdding: .day, value: -i, to: today)
            let ind = getDaySpendsInd(date: day!)
            if ind != i {
                if ind != -1 {
                    swap(&daily[i], &daily[ind])
                }
                else {
                    daily.insert(DaySpends(forDate: day!), at: i)
                }
            }
        }

        if daily.count > DAYS_HISTORY {
            daily.removeLast(daily.count - DAYS_HISTORY)
        }
    }

    private func getDaySpendsInd(date: Date) -> Int {
        for i in 0..<daily.count {
            if daily[i].date == date {
                return i
            }
        }
        
        return -1
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func fetchSpends() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        let calendar = Calendar.current

        for daySpends in daily {
            let dateend = calendar.date(byAdding: .day, value: 1, to: daySpends.date)

            do {
                fetchRequest.predicate = NSPredicate(format: "date >= %@ && date <%@", daySpends.date as NSDate, dateend! as NSDate)
                daySpends.spends = try context.fetch(fetchRequest)
            }
            catch let error {
                print("Failed to fetch spends. ERROR: " + error.localizedDescription)
            }
        }
    }

    public func addSpend(cat: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        checkDays()
        
        let context = getContext()
        let spendEntity = NSEntityDescription.entity(forEntityName: "Spend", in: context)

        let spend = NSManagedObject(entity: spendEntity!, insertInto: context) as! SpendModel
        spend.category = cat
        spend.comment = comment
        spend.date = Date()
        spend.sum = sum
        spend.currency = curIso
        spend.bsum = bsum
        spend.bcurrency = bcurIso
        
        do {
            //try context.save()
            daily[0].spends.insert(spend, at: 0)
        }
        catch let error {
            print("Failed to add spend. ERROR: " + error.localizedDescription)
        }
    }

    //let comps = calendar.dateComponents([.day, .month, .year], from: Date())
    //let today = calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day))
}


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
