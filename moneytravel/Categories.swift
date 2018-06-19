//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 17/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appCategories = AppCategories()

class AppCategories {
    private(set) var categories: [CategoryModel] = []
    
    init() {
        initBase()
    }
    
    private func initBase() {
        let context = get_context()
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
            ("Entertain", "Entertain"),
            ("Mobile", "Mobile"),
            
            //("Restaurant", "Restaurant"),
            //("Games", "Games"),
        ]
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                var pos: Int16 = 0
                for (iconname, name) in catList {
                    let category = NSManagedObject(entity: categoryEntity!, insertInto: context) as! CategoryModel
                    category.name = name
                    category.iconname = iconname
                    category.color = CATEGORY_DEFAULT
                    category.position = pos
                    
                    pos += 1
                }
                
                try context.save()
            }
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
            categories = try context.fetch(fetchRequest)
        }
        catch let error {
            print("Failed to init categories! ERROR: " + error.localizedDescription)
        }
    }
    
    public func add(name: String, iconname: String, color: UIColor) {
        let context = get_context()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        
        let category = NSManagedObject(entity: categoryEntity!, insertInto: context) as! CategoryModel
        category.name = name
        category.iconname = iconname
        category.color = color
        category.position = Int16(categories.count - 1)

        do {
            try context.save()
            categories.append(category)
        }
        catch let error {
            print("Failed to add category! ERROR: " + error.localizedDescription)
        }
    }
    
    public func move(fromPosition from: Int, to: Int) {
        if from == to || from < 0 || to < 0 || from >= categories.count || to >= categories.count {
            return
        }
        
        let catMoved = categories[from]
        
        var ind = from
        let delta = (to > from) ? 1 : -1
        
        while ind != to {
            categories[ind] = categories[ind + delta]
            ind += delta
        }
        
        categories[to] = catMoved
        invalidatePositions()
        get_delegate().saveContext()
    }
    
    private func invalidatePositions() {
        for i in 0..<categories.count {
            let ind: Int16 = Int16(i)
            
            if categories[i].position != ind {
                categories[i].position = ind
            }
        }
    }
    
    public func save() {
        get_delegate().saveContext()
    }
}
