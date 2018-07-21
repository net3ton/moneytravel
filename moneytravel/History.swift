//
//  History.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class HistoryInterval {
    var dateFrom: HistoryDate = HistoryDate()
    var dateTo: HistoryDate = HistoryDate()
    
    subscript(index: Int) -> (date: HistoryDate, minDate: Date?, label: String) {
        get {
            if index == 0 {
                return (date: dateFrom, minDate: nil, label: "From")
            }
            
            return (date: dateTo, minDate: dateFrom.getDate(), label: "To")
        }
    }
    
    var count: Int {
        get {
            return 2
        }
    }
}


class HistoryDate {
    private var stamp: MarkModel?
    private var date: Date?

    public func setDate(date: Date) {
        if let stamp = appTimestamps.find(for: date) {
            self.stamp = stamp
            self.date = nil
        }
        else {
            self.date = Calendar.current.startOfDay(for: date)
            self.stamp = nil
        }
    }

    public func setNow() {
        self.date = Date()
        self.stamp = nil
    }
    
    public func setToday() {
        setDate(date: Date())
    }

    public func setWeekAgo() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        setDate(date: weekAgo!)
    }

    public func setDaysAgo(days: Int) {
        let daysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date())
        setDate(date: daysAgo!)
    }

    public func setStamp(stamp: MarkModel) {
        self.stamp = stamp
        self.date = nil
    }

    public func getDate() -> Date {
        if date != nil {
            return date!
        }
        
        if stamp != nil {
            return stamp!.date!
        }

        return Calendar.current.startOfDay(for: Date())
    }
    
    public func getName() -> String {
        if stamp != nil {
            return stamp!.name!
        }
        
        if date != nil {
            if Calendar.current.isDateInToday(date!) {
                return "Today"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd LLLL yyyy"
            return formatter.string(from: date!)
        }
        
        return ""
    }
}
