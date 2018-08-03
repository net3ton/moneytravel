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
    private var dateToSync = Date()

    public func sync() {
        if appGoogleDrive.isLogined() && dateToSync < Date() {
            makeSync()
        }
    }

    private func makeSync() {
        print("[Sync] syncing...")
        self.dateToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

        appGoogleDrive.downloadFromRoot(filename: AppSync.NAME_SYNC) { (fileData, fileId, error) in
            if let fdata = fileData {
                if let appdata = AppData.loadFromData(fdata) {
                    self.importData(appdata)
                    print("[Sync] data imported.")
                }
                else {
                    print("[Sync] failed to load data!")
                    return
                }
            }

            if error == .none || error == .notFoundError {
                //self.syncUpload(to: fileId)
            }
            else {
                print("[Sync] failed to download sync base!")
            }
        }
    }
    
    private func syncUpload(to fileId: String?) {
        print("[Sync] uploading...")

        if let data = AppData().exportToData() {
            if let fid = fileId {
                appGoogleDrive.updateFile(data: data, fileid: fid) { (success) in
                    self.syncComplete(success)
                }
            }
            else {
                appGoogleDrive.uploadToRoot(data: data, filename: AppSync.NAME_SYNC) { (success) in
                    self.syncComplete(success)
                }
            }
        }
    }

    private func syncComplete(_ success: Bool) {
        if success {
            self.dateToSync = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
            appSettings.googleSyncDate = Date()
            appSettings.save()
            print("[Sync] ok.")
        }
        else {
            print("[Sync] failed to upload sync base!")
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
