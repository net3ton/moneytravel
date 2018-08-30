//
//  History.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

fileprivate let DAY_SECONDS = 24 * 3600

class HistoryInterval {
    var dateFrom: HistoryDate = HistoryDate()
    var dateTo: HistoryDate = HistoryDate()
    
    subscript(index: Int) -> (date: HistoryDate, minDate: Date?, label: String) {
        get {
            if index == 0 {
                return (date: dateFrom, minDate: nil, label: "D_FROM".loc())
            }
            
            return (date: dateTo, minDate: dateFrom.getDate(), label: "D_TO".loc())
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

    public func setStamp(_ stamp: MarkModel) {
        self.stamp = stamp
        self.date = nil
    }

    public func setDate(_ date: Date) {
        if let stamp = appTimestamps.find(for: date) {
            setStamp(stamp)
        }
        else {
            self.date = Calendar.current.startOfDay(for: date)
            self.stamp = nil
        }
    }
    
    public func setToday() {
        setDate(Date())
    }

    public func setWeekAgo() {
        setDaysAgo(days: 6)
    }

    public func setDaysAgo(days: Int) {
        let daysAgo = Calendar.current.date(byAdding: .day, value: -days, to: Date())
        setDate(daysAgo!)
    }

    public func getDate() -> Date {
        if stamp != nil {
            return stamp!.date!
        }

        if date != nil {
            return date!
        }

        return Date()
    }

    public func getName() -> String {
        if stamp != nil {
            return stamp!.name!
        }
        
        if let date = date {
            if Calendar.current.isDateInToday(date) {
                return "T_TODAY".loc()
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd LLLL yyyy"
            return formatter.string(from: date)
        }
        
        return ""
    }

    public func getDateFrom() -> Date {
        if date != nil {
            return date! + TimeInterval(appSettings.dayStart)
        }

        return getDate()
    }

    public func getDateTo() -> Date {
        if date != nil {
            return date! + TimeInterval(appSettings.dayStart + DAY_SECONDS)
        }

        return getDate()
    }
    
    static public func getPrevDate(_ date: Date, limited: Date) -> Date {
        let day = Calendar.current.startOfDay(for: date)
        var point = day + TimeInterval(appSettings.dayStart)
        
        if point >= date {
            point -= TimeInterval(DAY_SECONDS)
        }
        
        if point < limited {
            point = limited
        }
        
        return point
    }
    
    static public func isSameDay(_ date: Date, to basedate: Date) -> Bool {
        return Calendar.current.isDate(date - TimeInterval(appSettings.dayStart), inSameDayAs: basedate)
    }
    
    static public func normalize(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date - TimeInterval(appSettings.dayStart))
    }
}
