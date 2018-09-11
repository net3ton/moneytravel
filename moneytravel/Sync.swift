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
    public static let META_HASH = "hash"
    private var googleToSync = Date()
    private var icloudToSync = Date()

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
            makeSyncICloud()
        }
    }

    public func makeSyncICloud() {
        print("[Sync iCloud] syncing...")
        icloudToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        
        let fileData = appICloudDrive.loadFromFile(AppSync.NAME_SYNC)
        self.importData(fileData)

        if let data = AppData().exportToData() {
            if appICloudDrive.saveToFile(AppSync.NAME_SYNC, data: data) {
                self.icloudToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                appSettings.icloudSyncDate = Date()
                appSettings.save()
                print("[Sync iCloud] ok.")
                
                SettingsViewController.view?.updateLabels()
            }
        }
    }
    
    public func makeGoogleSync() {
        print("[Sync Google] syncing...")
        googleToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

        appGoogleDrive.lookupInRoot(filename: AppSync.NAME_SYNC) { (fileId, fileHash, error) in
            if error == .lookupError {
                print("[Sync Google] failed sync!")
                return
            }
            
            if let hash = fileHash, hash == appSettings.googleSyncLastHash {
                print("[Sync Google] server data hasn't changed - no need to download.")
                self.syncGoogleUpload(to: fileId, lastHash: hash)
                return
            }
            
            appGoogleDrive.downloadFile(fileid: fileId, completion: { (fileData, error) in
                if error == .downloadError {
                    print("[Sync Google] failed to download sync data!")
                    return
                }
                
                self.importData(fileData)
                self.syncGoogleUpload(to: fileId, lastHash: fileHash ?? "")
            })
        }
    }
    
    private func syncGoogleUpload(to fileId: String?, lastHash: String) {
        guard let data = AppData().exportToData() else {
            print("[Sync Google] failed to export data!")
            return
        }

        let curhash = AppData.getDataHash(data)
        if lastHash == curhash {
            print("[Sync Google] data hasn't changed since last time - no need to upload.")
            self.syncGoogleComplete(true, withHash: curhash)
            return
        }
        
        print("[Sync Google] uploading...")

        if let fid = fileId {
            appGoogleDrive.updateFile(data: data, fileid: fid, filehash: curhash, mime: .binary) { (success) in
                self.syncGoogleComplete(success, withHash: curhash)
            }
        }
        else {
            appGoogleDrive.uploadToRoot(data: data, filename: AppSync.NAME_SYNC, filehash: curhash, description: AppSync.DESC_SYNC, mime: .binary) { (success) in
                self.syncGoogleComplete(success, withHash: curhash)
            }
        }
    }

    private func syncGoogleComplete(_ success: Bool, withHash hash: String) {
        if success {
            googleToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            appSettings.googleSyncLastHash = hash
            appSettings.googleSyncDate = Date()
            appSettings.save()
            print("[Sync Google] ok.")
            
            SettingsViewController.view?.updateLabels()
        }
        else {
            print("[Sync Google] failed to upload sync base!")
        }
    }

    private func importData(_ data: Data?) {
        guard let fdata = data else {
            print("[Sync] no data to load!")
            return
        }
        
        guard let appdata = AppData.loadFromData(fdata) else {
            print("[Sync] failed to load data!")
            return
        }
        
        appdata.importData()
        print("[Sync] data imported.")
        
        DispatchQueue.main.async {
            appCategories.reload()
            lastSpends.reload()
            
            let main = top_view_controller() as? MainViewController
            main?.updateSpendsView()
        }
    }
}
