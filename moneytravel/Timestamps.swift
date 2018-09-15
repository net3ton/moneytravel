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
    public func fetchAll(removed: Bool = false, with context: NSManagedObjectContext = get_context()) -> [MarkModel] {
        let fetchRequest = NSFetchRequest<MarkModel>(entityName: "Mark")
        
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = removed ? nil : NSPredicate(format: "removed == NO")

            return try context.fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch timestamps! ERROR: " + error.localizedDescription)
        }
        
        return []
    }

    public func add(name: String, date: Date, color: UIColor, comment: String?) {
        let context = get_context()
        let markEntity = NSEntityDescription.entity(forEntityName: "Mark", in: context)
        
        let mark = MarkModel(entity: markEntity!, insertInto: context)
        mark.name = name
        mark.date = date
        mark.color = color
        mark.comment = comment
        mark.uid = getUID()
        
        do {
            try context.save()
            lastSpends.reload()
        }
        catch let error {
            print("Failed to add timestamp! ERROR: " + error.localizedDescription)
        }
    }

    public func add(name: String) {
        add(name: name, date: Date(), color: TIMESTAMP_DEFAULT, comment: nil)
    }
    
    public func find(for date: Date) -> MarkModel? {
        let context = get_context()
        let fetchRequest = NSFetchRequest<MarkModel>(entityName: "Mark")
        
        do {
            fetchRequest.predicate = NSPredicate(format: "date == %@ && removed == NO", date as NSDate)
            let result = try context.fetch(fetchRequest)
            if !result.isEmpty {
                return result[0]
            }
        }
        catch let error {
            print("Failed to find timestamp! ERROR: " + error.localizedDescription)
        }

        return nil
    }

    public func update(stamp: MarkModel) {
        stamp.version += 1
        get_delegate().saveContext()
        lastSpends.reload()
    }
    
    public func delete(stamp: MarkModel) {
        stamp.version += 1
        stamp.removed = true
        get_delegate().saveContext()
        lastSpends.reload()
    }
}
