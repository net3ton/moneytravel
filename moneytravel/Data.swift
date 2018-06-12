//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

public func num_to_string(sum: Float) -> String {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "\u{00a0}" // non-breaking space
    formatter.groupingSize = 3
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.minimumIntegerDigits = 1

    return formatter.string(from: NSNumber(value: sum)) ?? "0.00"
}

public func sum_to_string(sum: Float, currency: String) -> String {
    return String.init(format: "%@ %@", num_to_string(sum: sum), currency)
}

private func get_delegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

private func get_context() -> NSManagedObjectContext {
    return get_delegate().persistentContainer.viewContext
}


extension CategoryModel {
    var icon: UIImage? {
        return UIImage(named: iconname!)
    }

    var color: UIColor {
        get {
            let r: CGFloat = CGFloat(colorvalue & 0xFF) / 255.0
            let g: CGFloat = CGFloat(colorvalue >> 8 & 0xFF) / 255.0
            let b: CGFloat = CGFloat(colorvalue >> 16 & 0xFF) / 255.0
            let a: CGFloat = CGFloat(colorvalue >> 24 & 0xFF) / 255.0

            return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
        }
        set {
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            var a: CGFloat = 0
            newValue.getRed(&r, green: &g, blue: &b, alpha: &a)

            let ir = Int32(r * 255)
            let ig = Int32(g * 255) << 8
            let ib = Int32(b * 255) << 16
            let ia = Int32(a * 255) << 24
            colorvalue = ia + ib + ig + ir
        }
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


let appCategories = AppCategories()

class AppCategories {
    private(set) var categories: [CategoryModel] = []

    init() {
        initBase()
    }

    private func getDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    private func getContext() -> NSManagedObjectContext {
        return getDelegate().persistentContainer.viewContext
    }

    private func initBase() {
        let context = getContext()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")

        let catList = [
            ("Food", "Food"),
            ("House", "Rent"),
            ("Transport", "Transport"),
            ("Canteen", "Canteen"),
            ("Cafe", "Cafe"),
            ("Museum", "Museums"),
            ("Gift", "Gifts"),
            ("Clothes", "Clothes"),
            ("Entertain", "Entertain")

            //("Restaurant", "Restaurant"),
            //("Games", "Games"),
        ]

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                for (iconname, name) in catList {
                    let category = NSManagedObject(entity: categoryEntity!, insertInto: context) as! CategoryModel
                    category.name = name
                    category.iconname = iconname
                    category.color = CATEGORY_DEFAULT
                }

                try context.save()
            }
            
            categories = try context.fetch(fetchRequest)
        }
        catch let error {
            print("Failed to init categories! ERROR: " + error.localizedDescription)
        }
    }

    public func add(name: String, iconname: String, color: UIColor) {
        let context = getContext()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)

        let category = NSManagedObject(entity: categoryEntity!, insertInto: context) as! CategoryModel
        category.name = name
        category.iconname = iconname
        category.color = color

        do {
            try context.save()
            categories.append(category)
        }
        catch let error {
            print("Failed to add category! ERROR: " + error.localizedDescription)
        }
    }

    public func replace(fromPosition from: Int, to: Int) {
        if from >= 0 && from < categories.count && to >= 0 && to < categories.count {
            let temp = categories[from]
            categories[from] = categories[to]
            categories[to] = temp
        }
    }

    public func save() {
        getDelegate().saveContext()
    }
}


let appSpends = AppSpends()

class AppSpends {
    public class DaySpends {
        public var date: Date
        public var spends: [SpendModel] = []

        init(forDate: Date) {
            date = forDate
        }

        public func getBudgetInfo() -> (baseSum: String, budgetProgress: Float, budgetLeft: String, budgetPlus: Bool) {
            var bsum: Float = 0
            
            for spend in spends {
                if spend.bcurrency == appSettings.currencyBase {
                    bsum += spend.bsum
                }
            }

            let bsumStr = (bsum <= 0) ? "" : sum_to_string(sum: bsum, currency: appSettings.currencyBase)
            let budgetProgress: Float = bsum / appSettings.dailyMax
            let budgetPlus: Bool = appSettings.dailyMax >= bsum
            let budgetLeft: Float = (appSettings.dailyMax - bsum) * appSettings.exchangeRate
            let budgetLeftStr = String.init(format: "Budget left: %@", sum_to_string(sum: budgetLeft, currency: appSettings.currency))

            return (baseSum: bsumStr, budgetProgress: budgetProgress, budgetLeft: budgetLeftStr, budgetPlus: budgetPlus)
        }

        public func getDateSubname() -> String {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            if date == today {
                return "Today"
            }

            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            if date == yesterday {
                return "Yesterday"
            }

            return ""
        }
        
        public func getDateString() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd LLLL"
            return formatter.string(from: date)
        }

        public func isThisDay(testdate: Date) -> Bool {
            let calendar = Calendar.current
            return calendar.isDate(testdate, inSameDayAs: date)
        }
    }

    private let DAYS_HISTORY = 3
    private(set) var daily: [DaySpends]

    init() {
        daily = [DaySpends]()

        checkDays()
        fetchLast()
    }

    private func getDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    private func getContext() -> NSManagedObjectContext {
        return getDelegate().persistentContainer.viewContext
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

    private func fetchLast() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")
        let calendar = Calendar.current

        for daySpends in daily {
            let dateend = calendar.date(byAdding: .day, value: 1, to: daySpends.date)

            do {
                fetchRequest.predicate = NSPredicate(format: "date >= %@ && date <%@", daySpends.date as NSDate, dateend! as NSDate)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                daySpends.spends = try context.fetch(fetchRequest)
            }
            catch let error {
                print("Failed to fetch spend record! ERROR: " + error.localizedDescription)
            }
        }
    }

    public func add(category: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        checkDays()
        
        let context = getContext()
        let spendEntity = NSEntityDescription.entity(forEntityName: "Spend", in: context)

        let spend = NSManagedObject(entity: spendEntity!, insertInto: context) as! SpendModel
        spend.category = category
        spend.comment = comment
        spend.date = Date()
        spend.sum = sum
        spend.currency = curIso
        spend.bsum = bsum
        spend.bcurrency = bcurIso

        do {
            try context.save()
            daily[0].spends.insert(spend, at: 0)
        }
        catch let error {
            print("Failed to add spend. ERROR: " + error.localizedDescription)
        }
    }

    private func find(spend: SpendModel) -> (day: DaySpends, ind: Int)? {
        for dayInfo in daily {
            if let ind = dayInfo.spends.index(of: spend) {
                return (day: dayInfo, ind: ind)
            }
        }

        return nil
    }

    public func delete(spend: SpendModel) {
        getContext().delete(spend)
        getDelegate().saveContext()

        if let res = find(spend: spend) {
            res.day.spends.remove(at: res.ind)
        }
    }

    public func update(spend: SpendModel) {
        getDelegate().saveContext()

        if let res = find(spend: spend) {
            res.day.spends.remove(at: res.ind)
        }

        for dayInfo in daily {
            if dayInfo.isThisDay(testdate: spend.date!) {
                for i in 0..<dayInfo.spends.count {
                    if dayInfo.spends[i].date! < spend.date! {
                        dayInfo.spends.insert(spend, at: i)
                        return
                    }
                }

                dayInfo.spends.append(spend)
                return
            }
        }
    }

    //let comps = calendar.dateComponents([.day, .month, .year], from: Date())
    //let today = calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day))
}

let appStats = AppStats()

class AppStats {
    
    init() {
    }

    public func getSumSince(date: Date) -> Float {
        let context = get_context()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        //let dateDays = Calendar.current.dateComponents([.day], from: date, to: Date())
        //let daysCount = Float(max(dateDays.day ?? 1, 1))
        var sum: Float = 0.0

        do {
            fetchRequest.predicate = NSPredicate(format: "date >= %@", date as NSDate)
            let spends = try context.fetch(fetchRequest)

            for sinfo in spends {
                sum += sinfo.bsum
            }
        }
        catch let error {
            print("Failed to fetch spends for stats! ERROR: " + error.localizedDescription)
        }

        return sum
    }
}

