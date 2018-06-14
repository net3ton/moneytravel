//
//  History.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class HistoryDate {
    private var mark: MarkModel?
    private var date: Date?
    
    public func setDate(date: Date) {
        self.date = date
        self.mark = nil
    }

    public func setToday() {
        setDate(date: Date())
    }

    public func setWeekAgo() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        setDate(date: weekAgo!)
    }

    public func setMark(mark: MarkModel) {
        self.mark = mark
        self.date = nil
    }
    
    public func getDate() -> Date {
        if date != nil {
            return date!
        }
        
        if mark != nil {
            return mark!.date!
        }
        
        return Date()
    }
    
    public func getName() -> String {
        if mark != nil {
            return mark!.name!
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
