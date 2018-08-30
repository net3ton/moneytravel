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
    public static let NAME_SYNC = "moneytravel.sync"
    public static let DESC_SYNC = "TravelMoney sync data"
    private var googleToSync = Date()

    public func syncGoogle() {
        if appGoogleDrive.isLogined() && googleToSync < Date() {
            makeGoogleSync()
        }
    }

    public func syncICloud() {
        if appSettings.isICloudEnabled() {
            makeSyncICloud()
        }
    }

    public func makeSyncICloud() {
        print("[Sync iCloud] syncing...")
        
        let fileData = appICloudDrive.loadFromFile(AppSync.NAME_SYNC)
        if let fdata = fileData {
            if let appdata = AppData.loadFromData(fdata) {
                //self.importData(appdata)
                print("[Sync iCloud] data imported.")
            }
            else {
                print("[Sync iCloud] failed to load data!")
            }
        }

        if let data = AppData().exportToData() {
            if appICloudDrive.saveToFile(AppSync.NAME_SYNC, data: data) {
                appSettings.icloudSyncDate = Date()
                appSettings.save()
                print("[Sync iCloud] ok.")
            }
        }
    }
    
    private func makeGoogleSync() {
        print("[Sync Google] syncing...")
        googleToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

        appGoogleDrive.downloadFromRoot(filename: AppSync.NAME_SYNC) { (fileData, fileId, error) in
            if let fdata = fileData {
                if let appdata = AppData.loadFromData(fdata) {
                    //self.importData(appdata)
                    print("[Sync Google] data imported.")
                }
                else {
                    print("[Sync Google] failed to load data!")
                    return
                }
            }

            if error == .none || error == .notFoundError {
                self.syncGoogleUpload(to: fileId)
            }
            else {
                print("[Sync Google] failed to download sync base!")
            }
        }
    }
    
    private func syncGoogleUpload(to fileId: String?) {
        print("[Sync Google] uploading...")

        if let data = AppData().exportToData() {
            if let fid = fileId {
                appGoogleDrive.updateFile(data: data, fileid: fid, mime: .binary) { (success) in
                    self.syncGoogleComplete(success)
                }
            }
            else {
                appGoogleDrive.uploadToRoot(data: data, filename: AppSync.NAME_SYNC, description: AppSync.DESC_SYNC, mime: .binary) { (success) in
                    self.syncGoogleComplete(success)
                }
            }
        }
    }

    private func syncGoogleComplete(_ success: Bool) {
        if success {
            googleToSync = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
            appSettings.googleSyncDate = Date()
            appSettings.save()
            print("[Sync Google] ok.")
        }
        else {
            print("[Sync Google] failed to upload sync base!")
        }
    }

    private func importData(_ appdata: AppData) {
        print("[Sync] base: "  + appdata.baseId)
        print("[Sync] timestamps: "  + String(appdata.timestamps.count))
        print("[Sync] categories: "  + String(appdata.categories.count))
        print("[Sync] spends: "  + String(appdata.spends.count))

        let context = get_context()
        context.mergePolicy = NSOverwriteMergePolicy

        var tstampCount = 0
        var catCount = 0
        var spendCount = 0

        for tstamp in appdata.timestamps {
            if appTimestamps.shouldUpdate(uid: tstamp.uid!, ver: tstamp.version) {
                context.insert(tstamp)
                tstampCount += 1
            }
        }
        for cat in appdata.categories {
            if appCategories.shouldUpdate(uid: cat.uid!, ver: cat.version) {
                context.insert(cat)
                catCount += 1
            }
        }
        for spend in appdata.spends {
            if appSpends.shouldUpdate(uid: spend.uid!, ver: spend.version) {
                context.insert(spend)
                spendCount += 1
            }
        }

        get_delegate().saveContext()
        print("[Sync] saved.")
        print("[Sync] timestamps updated: " + String(tstampCount))
        print("[Sync] categories updated: " + String(catCount))
        print("[Sync] spends updated: " + String(spendCount))

        DispatchQueue.main.async {
            appCategories.reload()
            lastSpends.reload()
        }
    }
}
