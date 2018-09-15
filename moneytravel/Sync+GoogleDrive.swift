//
//  Sync+GoogleDrive.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

extension AppSync {
    private static let NAME_SYNC = "moneytravel.sync"
    private static let DESC_SYNC = "TravelMoney sync data"
    
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
                self.googleUpload(to: fileId, lastHash: hash)
                return
            }
            
            appGoogleDrive.downloadFile(fileid: fileId, completion: { (fileData, error) in
                if error == .downloadError {
                    print("[Sync Google] failed to download sync data!")
                    return
                }
                
                self.importData(fileData, with: get_context())
                self.googleUpload(to: fileId, lastHash: fileHash ?? "")
            })
        }
    }

    private func googleUpload(to fileId: String?, lastHash: String) {
        guard let data = AppData().exportToData() else {
            print("[Sync Google] failed to export data!")
            return
        }
        
        let curhash = AppData.getDataHash(data)
        if lastHash == curhash {
            print("[Sync Google] data hasn't changed since last time - no need to upload.")
            self.googleComplete(true, withHash: curhash)
            return
        }
        
        print("[Sync Google] uploading...")
        
        if let fid = fileId {
            appGoogleDrive.updateFile(data: data, fileid: fid, filehash: curhash, mime: .binary) { (success) in
                self.googleComplete(success, withHash: curhash)
            }
        }
        else {
            appGoogleDrive.uploadToRoot(data: data, filename: AppSync.NAME_SYNC, filehash: curhash, description: AppSync.DESC_SYNC, mime: .binary) { (success) in
                self.googleComplete(success, withHash: curhash)
            }
        }
    }

    private func googleComplete(_ success: Bool, withHash hash: String) {
        if success {
            googleToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            appSettings.googleSyncLastHash = hash
            appSettings.googleSyncDate = Date()
            appSettings.save()
            print("[Sync Google] ok.")
            
            DispatchQueue.main.async {
                SettingsViewController.view?.updateLabels()
            }
        }
        else {
            print("[Sync Google] failed to upload sync base!")
        }
    }
}
