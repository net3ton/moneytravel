//
//  Categories.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 17/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let DEFAULT_CATEGORIES = [
    ("Food", "Products", "UID-Prods"),          // Products
    ("House", "Rent", "UID-Rent"),              // Rent
    ("Transport", "Transport", "UID-Trans"),    // Transport
    ("Canteen", "Dinner", "UID-Dinner"),        // Dinner
    ("Cafe", "Cafe", "UID-Cafe"),               // Cafe
    ("Museum", "Museums", "UID-Museums"),       // Museums
    ("Gift", "Gifts", "UID-Gifts"),             // Gifts
    ("Clothes", "Clothes", "UID-Clothes"),      // Clothes
    ("Entertain", "Entertain", "UID-Relax"),    // Relax
    ("Mobile", "Mobile", "UID-Mobile"),         // Mobile
]

let appCategories = AppCategories()

class AppCategories {
    private(set) var categories: [CategoryModel] = []

    init() {
        initCategories()
        reload()
    }

    private func initCategories() {
        let context = get_context()
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                var pos: Int16 = 0
                for (iconname, name, uid) in DEFAULT_CATEGORIES {
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
    }

    public func reload() {
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
        category.uid = getUID()

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

    public func getCategory(by uid: String) -> CategoryModel? {
        for cat in categories {
            if cat.uid == uid {
                return cat
            }
        }

        return nil
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
