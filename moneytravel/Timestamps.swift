//
//  Timestamps.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appTimestamps = AppTimestamps()

class AppTimestamps {
    private (set) var marks: [MarkModel] = []
    
    public func fetch() {
        do {
            let fetchRequest = NSFetchRequest<MarkModel>(entityName: "Mark")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            marks = try get_context().fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch time marks! ERROR: " + error.localizedDescription)
        }
    }
    
    private func addToMarks(_ stamp: MarkModel) {
        for i in 0..<marks.count {
            if marks[i].date! < stamp.date! {
                marks.insert(stamp, at: i)
                return
            }
        }

        marks.append(stamp)
    }
    
    public func add(name: String, date: Date, color: UIColor) {
        let context = get_context()
        let markEntity = NSEntityDescription.entity(forEntityName: "Mark", in: context)
        
        let mark = NSManagedObject(entity: markEntity!, insertInto: context) as! MarkModel
        mark.name = name
        mark.date = date
        mark.color = color
        
        do {
            try context.save()
            addToMarks(mark)
        }
        catch let error {
            print("Failed to add time mark! ERROR: " + error.localizedDescription)
        }
    }

    public func find(date: Date) -> MarkModel? {
        let ind = findIndex(date: date)
        if ind != -1 {
            return marks[ind]
        }

        return nil
    }

    public func findIndex(date: Date) -> Int {
        for i in 0..<marks.count {
            if marks[i].date == date {
                return i
            }
        }

        return -1
    }

    public func save() {
        get_delegate().saveContext()
    }
    
    public func delete(stamp: MarkModel) {
        get_context().delete(stamp)
        get_delegate().saveContext()
        
        if let ind = marks.index(of: stamp) {
            marks.remove(at: ind)
        }
    }
}


