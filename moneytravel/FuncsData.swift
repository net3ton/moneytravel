//
//  FuncsData.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 15/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

func getUID() -> String {
    let timestamp =  UInt((Date().timeIntervalSince1970 * 1000000.0).rounded())
    
    let p1: UInt32 = UInt32(timestamp & 0xFFFFFFFF)
    let p2: UInt32 = UInt32(timestamp >> 32) | UInt32(arc4random() << 16)
    
    return String(format:"%08X%08X", p2, p1)
}

func get_delegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func get_context() -> NSManagedObjectContext {
    return get_delegate().persistentContainer.viewContext
}

func reset_all_data() {
    do {
        let context = get_context()
        try context.execute(NSBatchDeleteRequest(fetchRequest: SpendModel.fetchRequest()))
        try context.execute(NSBatchDeleteRequest(fetchRequest: MarkModel.fetchRequest()))
        appCategories.removeAll(with: context)
        try context.save()
    }
    catch let error {
        print("Failed to reset data! ERROR: " + error.localizedDescription)
    }
}
