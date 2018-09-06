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
    private var icloudToSync = Date()

    public func sync() {
        syncGoogle()
        syncICloud()
    }
    
    private func syncGoogle() {
        if appGoogleDrive.isLogined() && googleToSync < Date() {
            makeGoogleSync()
        }
    }

    private func syncICloud() {
        if appSettings.isICloudEnabled() && icloudToSync < Date() {
            makeSyncICloud()
        }
    }

    public func makeSyncICloud() {
        print("[Sync iCloud] syncing...")
        icloudToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        
        let fileData = appICloudDrive.loadFromFile(AppSync.NAME_SYNC)
        if let fdata = fileData {
            if let appdata = AppData.loadFromData(fdata) {
                self.importData(appdata)
                print("[Sync iCloud] data imported.")
            }
            else {
                print("[Sync iCloud] failed to load data!")
            }
        }

        if let data = AppData().exportToData() {
            if appICloudDrive.saveToFile(AppSync.NAME_SYNC, data: data) {
                self.icloudToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                appSettings.icloudSyncDate = Date()
                appSettings.save()
                print("[Sync iCloud] ok.")
            }
        }
    }
    
    public func makeGoogleSync() {
        print("[Sync Google] syncing...")
        googleToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

        appGoogleDrive.downloadFromRoot(filename: AppSync.NAME_SYNC) { (fileData, fileId, error) in
            if let fdata = fileData {
                if let appdata = AppData.loadFromData(fdata) {
                    self.importData(appdata)
                    print("[Sync Google] data imported.")
                }
                else {
                    print("[Sync Google] failed to load data!")
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
            googleToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            appSettings.googleSyncDate = Date()
            appSettings.save()
            print("[Sync Google] ok.")
        }
        else {
            print("[Sync Google] failed to upload sync base!")
        }
    }

    private func importData(_ appdata: AppData) {
        appdata.importData()

        DispatchQueue.main.async {
            appCategories.reload()
            lastSpends.reload()
            
            let main = top_view_controller() as? MainViewController
            main?.updateSpendsView()
        }
    }
}
