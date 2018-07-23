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
        let catList = [
            ("Food", "Food", "UID-Food"),
            ("House", "Rent", "UID-Rent"),
            ("Transport", "Transport", "UID-Transport"),
            ("Canteen", "Canteen", "UID-Canteen"),
            ("Cafe", "Cafe", "UID-Cafe"),
            ("Museum", "Museums", "UID-Museum"),
            ("Gift", "Gifts", "UID-Gifts"),
            ("Clothes", "Clothes", "UID-Clothes"),
            ("Entertain", "Entertain", "UID-Enertain"),
            ("Mobile", "Mobile", "UID-Mobile"),
        ]

        let context = get_context()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                var pos: Int16 = 0
                for (iconname, name, uid) in catList {
                    let category = CategoryModel(entity: categoryEntity!, insertInto: context)
                    category.name = name
                    category.iconname = iconname
                    category.color = CATEGORY_DEFAULT
                    category.position = pos
                    category.uid = uid
                    pos += 1
                }
                
                try context.save()
            }
        }
        catch let error {
            print("Failed to init categories! ERROR: " + error.localizedDescription)
        }

        categories = fetchAll(removed: false)
    }

    public func fetchAll(removed: Bool) -> [CategoryModel] {
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")
        
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
            fetchRequest.predicate = removed ? nil : NSPredicate(format: "removed == NO")

            return try get_context().fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch categories! ERROR: " + error.localizedDescription)
        }

        return []
    }

    public func add(name: String, iconname: String, color: UIColor) {
        let context = get_context()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        
        let category = CategoryModel(entity: categoryEntity!, insertInto: context)
        category.name = name
        category.iconname = iconname
        category.color = color
        category.position = Int16(categories.count)
        category.uid = UUID().uuidString

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

    public func delete(category: CategoryModel) {
        category.removed = true
        get_delegate().saveContext()

        if let ind = categories.index(of: category) {
            categories.remove(at: ind)
        }
    }
}
