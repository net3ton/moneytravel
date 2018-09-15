//
//  EntityChecker.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appSpendChecker = AppEntityChecker(SpendModel.fetchRequest())
let appCategoryChecker = AppEntityChecker(CategoryModel.fetchRequest())
let appTStampChecker = AppEntityChecker(MarkModel.fetchRequest())

class AppEntityChecker {
    private var versionRequest: NSFetchRequest<NSFetchRequestResult>
    
    init(_ request: NSFetchRequest<NSFetchRequestResult>) {
        versionRequest = request
    }
    
    public func shouldUpdate(uid: String, ver: Int16, with context: NSManagedObjectContext) -> Bool {
        versionRequest.predicate = NSPredicate(format: "uid == %@ && version >= %d", uid, ver)
        
        do {
            return try context.count(for: versionRequest) == 0
        }
        catch let error {
            print("Failed to check record version! ERROR: " + error.localizedDescription)
        }
        
        return false
    }
}
