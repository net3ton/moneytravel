//
//  Spends.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 17/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

class DaySpends {
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
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


let appSpends = AppSpends()

class AppSpends {
    
    private let DAYS_HISTORY = 3
    private(set) var daily: [DaySpends]
    
    init() {
        daily = [DaySpends]()
        
        checkDays()
        fetchLast()
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
        let context = get_context()
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")
        let calendar = Calendar.current
        
        for daySpends in daily {
            let dateend = calendar.date(byAdding: .day, value: 1, to: daySpends.date)
            
            do {
                fetchRequest.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", daySpends.date as NSDate, dateend! as NSDate)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                daySpends.spends = try context.fetch(fetchRequest)
            }
            catch let error {
                print("Failed to fetch spend record! ERROR: " + error.localizedDescription)
            }
        }
    }

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
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")
        
        while current <= last {
            let next = Calendar.current.date(byAdding: .day, value: 1, to: current)!
            
            do {
                fetchRequest.predicate = NSPredicate(format: "date >= %@ && date <%@ && removed == NO", current as NSDate, next as NSDate)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                let spends = try context.fetch(fetchRequest)
                
                let daySpends = DaySpends(forDate: current)
                daySpends.spends = spends
                history.append(daySpends)
            }
            catch let error {
                print("Failed to fetch spend record! ERROR: " + error.localizedDescription)
            }
            
            current = next
        }
        
        history.reverse()
        return history
    }
    
    public func add(category: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        checkDays()
        
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
        spend.removed = true
        get_delegate().saveContext()

        if let res = find(spend: spend) {
            res.day.spends.remove(at: res.ind)
        }
    }

    public func update(spend: SpendModel) {
        get_delegate().saveContext()
        
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
}
