//
//  History.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class HistoryDate {
    private var stamp: MarkModel?
    private var date: Date?

    public func setDate(date: Date) {
        if let stamp = appTimestamps.find(date: date) {
            self.stamp = stamp
            self.date = nil
        }
        else {
            self.date = Calendar.current.startOfDay(for: date)
            self.stamp = nil
        }
    }

    public func setToday() {
        setDate(date: Date())
    }

    public func setWeekAgo() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        setDate(date: weekAgo!)
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
