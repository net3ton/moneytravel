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
    ("Food", "CAT_PRODUCTS".loc(), "UID-Prods"),          // Products
    ("House", "CAT_RENT".loc(), "UID-Rent"),              // Rent
    ("Transport", "CAT_TRANSPORT".loc(), "UID-Trans"),    // Transport
    ("Canteen", "CAT_DINNER".loc(), "UID-Dinner"),        // Dinner
    ("Cafe", "CAT_CAFE".loc(), "UID-Cafe"),               // Cafe
    ("Museum", "CAT_MUSEUMS".loc(), "UID-Museums"),       // Museums
    ("Gift", "CAT_GIFTS".loc(), "UID-Gifts"),             // Gifts
    ("Clothes", "CAT_CLOTHES".loc(), "UID-Clothes"),      // Clothes
    ("Entertain", "CAT_ENTERTAIN".loc(), "UID-Relax"),    // Relax
    ("Mobile", "CAT_MOBILE".loc(), "UID-Mobile"),         // Mobile
    ("Pills", "CAT_HEALTH".loc(), "UID-Health"),          // Health
    ("Taxes", "CAT_BILLS".loc(), "UID-Bills"),            // Bills
]

let appCategories = AppCategories()

class AppCategories {
    private(set) var categories: [CategoryModel] = []

    init() {
        initCategories()
        reload()
    }
    
    public func initCategories() {
        let context = get_context()
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                inserDefaultCategories(into: context)
                try context.save()
            }
        }
        catch let error {
            print("Failed to init categories! ERROR: " + error.localizedDescription)
        }
    }

    private func inserDefaultCategories(into context: NSManagedObjectContext) {
        var pos: Int16 = 0
        for (iconname, name, uid) in DEFAULT_CATEGORIES {
            let category = CategoryModel(entity: CategoryModel.entity(), insertInto: context)
            category.name = name
            category.iconname = iconname
            category.color = CATEGORY_DEFAULT
            category.position = pos
            category.uid = uid
            pos += 1
        }
    }
    
    public func reload() {
        categories = fetchAll(removed: false)
    }
    
    public func fetchAll(removed: Bool, with context: NSManagedObjectContext = get_context()) -> [CategoryModel] {
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")
        
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
            fetchRequest.predicate = removed ? nil : NSPredicate(format: "removed == NO")

            return try context.fetch(fetchRequest)
        }
        catch let error {
            print("Failed to fetch categories! ERROR: " + error.localizedDescription)
        }

        return []
    }
    
    public func removeAll(with context: NSManagedObjectContext) {
        for cat in fetchAll(removed: true, with: context) {
            context.delete(cat)
        }
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

    public func update(category: CategoryModel) {
        category.version += 1
        get_delegate().saveContext()
    }

    public func delete(category: CategoryModel) {
        category.version += 1
        category.removed = true
        get_delegate().saveContext()

        if let ind = categories.firstIndex(of: category) {
            categories.remove(at: ind)
        }
    }
}
