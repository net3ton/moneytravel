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
}


class DaySpends {
    private(set) var date: Date
    private(set) var spends: [SpendModel]
    private(set) var tmarks: [MarkModel]

    //private(set) var items: [DaySpendsItem] = []

    init(forDate: Date, spends: [SpendModel], tmarks: [MarkModel]) {
        self.date = forDate
        self.spends = spends
        self.tmarks = tmarks
    }

    public func getItemsCount() -> Int {
        return spends.count + tmarks.count
    }

    public func getItem(ind: Int) -> DaySpendsItem {
        var items: [DaySpendsItem] = []

        var spendInd = 0
        var tmarkInd = 0

        while spendInd < spends.count || tmarkInd < tmarks.count {
            if spendInd >= spends.count {
                let item = DaySpendsItem(spend: nil, tmark: tmarks[tmarkInd])
                tmarkInd += 1

                items.append(item)
                continue
            }

            if tmarkInd >= tmarks.count {
                let item = DaySpendsItem(spend: spends[spendInd], tmark: nil)
                spendInd += 1
                
                items.append(item)
                continue
            }

            if spends[spendInd].date! > tmarks[tmarkInd].date! {
                let item = DaySpendsItem(spend: spends[spendInd], tmark: nil)
                spendInd += 1
                
                items.append(item)
                continue
            }
            else {
                let item = DaySpendsItem(spend: nil, tmark: tmarks[tmarkInd])
                tmarkInd += 1
                
                items.append(item)
                continue
            }
        }

        return items[ind]
    }

    public func getSpendSum() -> Float {
        var bsum: Float = 0

        for spend in spends {
            if spend.bcurrency == appSettings.currencyBase {
                bsum += spend.bsum
            }
        }

        return bsum
    }

    public func getBudgetInfo() -> (baseSum: String, budgetProgress: Float, budgetLeft: String, budgetPlus: Bool) {
        let bsum = getSpendSum()
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

    public func add(_ spend: SpendModel) {
        for item in spends.enumerated() {
            if spend.date! > item.element.date! {
                spends.insert(spend, at: item.offset)
                return
            }
        }

        spends.append(spend)
    }

    public func add(_ tmark: MarkModel) {
        for item in tmarks.enumerated() {
            if tmark.date! > item.element.date! {
                tmarks.insert(tmark, at: item.offset)
                return
            }
        }
        
        tmarks.append(tmark)
    }

    public func delete(_ spend: SpendModel) {
        if let ind = spends.index(of: spend) {
            spends.remove(at: ind)
        }
    }
    
    public func delete(_ tmark: MarkModel) {
        if let ind = tmarks.index(of: tmark) {
            tmarks.remove(at: ind)
        }
    }
}


let lastSpends = LastSpends()

class LastSpends {
    private let DAYS_HISTORY = 3
    private(set) var daily: [DaySpends] = []
    
    init() {
        daily = fetchLast()
    }

    private func fetchLast() -> [DaySpends] {
        let interval = HistoryInterval()
        interval.dateTo.setNow()
        interval.dateFrom.setDaysAgo(days: DAYS_HISTORY-1)

        return appSpends.fetch(for: interval)
    }

    private func checkDays() {
        if !daily[0].isThisDay(Date()) {
            daily = fetchLast()
        }
    }

    public func addSpend(_ spend: SpendModel) {
        daily[0].add(spend)
    }

    public func addTMark(_ tmark: MarkModel) {
        daily[0].add(tmark)
    }

    public func deleteSpend(_ spend: SpendModel) {
        for dayInfo in daily {
            dayInfo.delete(spend)
        }
    }

    public func deleteTMark(_ tmark: MarkModel) {
        for dayInfo in daily {
            dayInfo.delete(tmark)
        }
    }

    public func updateSpend(_ spend: SpendModel) {
        deleteSpend(spend)

        for dayInfo in daily {
            if dayInfo.isThisDay(spend.date!) {
                dayInfo.add(spend)
                break
            }
        }
    }

    public func updateTMark(_ tmark: MarkModel) {
        deleteTMark(tmark)
        
        for dayInfo in daily {
            if dayInfo.isThisDay(tmark.date!) {
                dayInfo.add(tmark)
                break
            }
        }
    }
}


let appSpends = AppSpends()

class AppSpends {
    public func fetchAll(removed: Bool) -> [SpendModel] {
        var result: [SpendModel] = []

        let context = get_context()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            fetchRequest.predicate = removed ? nil : NSPredicate(format: "removed == NO")

            result = try context.fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch all spend records! ERROR: " + error.localizedDescription)
        }

        return result
    }

    public func fetch(for interval: HistoryInterval) -> [DaySpends] {
        var history: [DaySpends] = []
        
        var current = interval.dateFrom.getDate()
        let last = interval.dateTo.getDate()
        
        if current > last {
            return history
        }
        
        let context = get_context()
        let fetchSpends = NSFetchRequest<SpendModel>(entityName: "Spend")
        let fetchMarks = NSFetchRequest<MarkModel>(entityName: "Mark")
        
        while current <= last {
            let next = Calendar.current.date(byAdding: .day, value: 1, to: current)!
            
            do {
                fetchSpends.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", current as NSDate, next as NSDate)
                fetchSpends.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                let spends = try context.fetch(fetchSpends)
                
                fetchMarks.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", current as NSDate, next as NSDate)
                fetchMarks.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                let tmarks = try context.fetch(fetchMarks)
                
                let daySpends = DaySpends(forDate: current, spends: spends, tmarks: tmarks)
                history.append(daySpends)
            }
            catch let error {
                print("Failed to fetch history! ERROR: " + error.localizedDescription)
            }

            current = next
        }

        history.reverse()
        return history
    }
    
    public func add(category: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        let context = get_context()
        let spendEntity = NSEntityDescription.entity(forEntityName: "Spend", in: context)
        
        let spend = SpendModel(entity: spendEntity!, insertInto: context)
        spend.category = category
        spend.comment = comment
        spend.date = Date()
        spend.sum = sum
        spend.currency = curIso
        spend.bsum = bsum
        spend.bcurrency = bcurIso
        //spend.uid = UUID().uuidString

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
        lastSpends.deleteSpend(spend)
    }

    public func update(spend: SpendModel) {
        get_delegate().saveContext()
        lastSpends.updateSpend(spend)
    }
}
