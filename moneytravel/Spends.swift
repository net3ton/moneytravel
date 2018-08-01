//
//  Spends.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 17/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

struct DaySpendsItem {
    var spend: SpendModel?
    var tmark: MarkModel?

    var date: Date {
        if let spend = spend {
            return spend.date!
        }

        if let tmark = tmark {
            return tmark.date!
        }

        return Date()
    }
}


class DaySpends {
    private(set) var date: Date
    private(set) var spends: [SpendModel]
    private(set) var tmarks: [MarkModel]

    private(set) var items: [DaySpendsItem]

    init(forDate: Date, spends: [SpendModel], tmarks: [MarkModel]) {
        self.date = forDate
        self.spends = spends
        self.tmarks = tmarks
        self.items = []

        for spend in spends {
            self.items.append(DaySpendsItem(spend: spend, tmark: nil))
        }
        for tmark in tmarks {
            self.items.append(DaySpendsItem(spend: nil, tmark: tmark))
        }

        sortItems()
    }

    private func sortItems() {
        items.sort { (item1, item2) -> Bool in
            return item1.date > item2.date
        }
    }

    public func getSpendBaseSum() -> Float {
        var bsum: Float = 0

        for spend in spends {
            if spend.bcurrency == appSettings.currencyBase {
                bsum += spend.bsum
            }
        }

        return bsum
    }

    public func getBudgetInfo() -> (baseSum: String, budgetProgress: Float, budgetLeft: String, budgetPlus: Bool) {
        let bsum = getSpendBaseSum()
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
    
    public func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd LLLL"
        return formatter.string(from: date)
    }

    public func isThisDay(_ testdate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(testdate, inSameDayAs: date)
    }

    ///

    public func add(spend: SpendModel?, tmark: MarkModel?) {
        if let spend = spend {
            spends.insert(spend, at: 0)
        }
        if let tmark = tmark {
            tmarks.insert(tmark, at: 0)
        }

        items.insert(DaySpendsItem(spend: spend, tmark: tmark), at: 0)
    }
}


let lastSpends = LastSpends()

class LastSpends {
    private let DAYS_HISTORY = 3
    private(set) var daily: [DaySpends] = []
    
    init() {
        reload()
    }

    public func reload() {
        daily = fetchLast()
    }

    private func fetchLast() -> [DaySpends] {
        let interval = HistoryInterval()
        interval.dateTo.setNow()
        interval.dateFrom.setDaysAgo(days: DAYS_HISTORY-1)

        return appSpends.fetch(for: interval)
    }

    public func checkDays() {
        if !daily[0].isThisDay(Date()) {
            daily = fetchLast()
        }
    }

    public func addSpend(_ spend: SpendModel) {
        checkDays()
        daily[0].add(spend: spend, tmark: nil)
    }
}


let appSpends = AppSpends()

class AppSpends {
    public func fetchAll(removed: Bool) -> [SpendModel] {
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            fetchRequest.predicate = removed ? nil : NSPredicate(format: "removed == NO")

            return try get_context().fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch all spend records! ERROR: " + error.localizedDescription)
        }

        return []
    }

    public func fetch(for interval: HistoryInterval) -> [DaySpends] {
        var history: [DaySpends] = []
        
        let first = interval.dateFrom.getDate()
        let last = interval.dateTo.getDate()

        if first > last {
            return history
        }

        var current = last
        if last == Calendar.current.startOfDay(for: last) {
            current = Calendar.current.date(byAdding: .day, value: 1, to: last)!
        }

        let context = get_context()
        let fetchSpends = NSFetchRequest<SpendModel>(entityName: "Spend")
        let fetchMarks = NSFetchRequest<MarkModel>(entityName: "Mark")

        while current > first {
            let prevDay = Calendar.current.date(byAdding: .second, value: -1, to: current)!
            var from = Calendar.current.startOfDay(for: prevDay)
            if from < first {
                from = first
            }

            do {
                fetchSpends.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", from as NSDate, current as NSDate)
                fetchSpends.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                let spends = try context.fetch(fetchSpends)
                
                fetchMarks.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", from as NSDate, current as NSDate)
                fetchMarks.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                let tmarks = try context.fetch(fetchMarks)
                
                let daySpends = DaySpends(forDate: from, spends: spends, tmarks: tmarks)
                history.append(daySpends)
            }
            catch let error {
                print("Failed to fetch history! ERROR: " + error.localizedDescription)
            }
            
            current = from
        }

        return history
    }
    
    public func add(category: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        let context = get_context()
        let spendEntity = NSEntityDescription.entity(forEntityName: "Spend", in: context)
        
        let spend = SpendModel(entity: spendEntity!, insertInto: context)
        spend.catid = category.uid
        spend.comment = comment
        spend.date = Date()
        spend.sum = sum
        spend.currency = curIso
        spend.bsum = bsum
        spend.bcurrency = bcurIso
        spend.uid = getUID()

        do {
            try context.save()
            lastSpends.addSpend(spend)
        }
        catch let error {
            print("Failed to add spend. ERROR: " + error.localizedDescription)
        }
    }

    public func delete(spend: SpendModel) {
        spend.removed = true
        get_delegate().saveContext()
        lastSpends.reload()
    }

    public func update(spend: SpendModel) {
        //spend.version += 1
        get_delegate().saveContext()
        lastSpends.reload()
    }
}
