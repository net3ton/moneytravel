//
//  Sync.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

let appSync = AppSync()

class AppSync {
    internal var googleToSync = Date()
    internal var icloudToSync = Date()
    
    public func sync() {
        syncICloud()
        syncGoogle()
    }
    
    private func syncGoogle() {
        if appGoogleDrive.isLogined() && googleToSync < Date() {
            makeGoogleSync()
        }
    }

    private func syncICloud() {
        if appSettings.isICloudEnabled() && icloudToSync < Date() {
            makeICloudSync()
        }
    }

    internal func importData(_ data: Data?, with context: NSManagedObjectContext) {
        guard let fdata = data else {
            print("[Sync] no data to load!")
            return
        }
        
        guard let appdata = AppData.loadFromData(fdata) else {
            print("[Sync] failed to load data!")
            return
        }
        
        appdata.importData(with: context)
        print("[Sync] data imported.")
        
        DispatchQueue.main.async {
            appCategories.reload()
            lastSpends.reload()
            
            let main = top_view_controller() as? MainViewController
            main?.updateSpendsView()
        }
    }
}
