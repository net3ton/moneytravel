//
//  SyncGoogleDrive.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

class SyncGoogleDrive: SyncTask {
    private static let NAME_SYNC = "moneytravel.sync"
    private static let DESC_SYNC = "TravelMoney sync data"
    
    override var type: SyncTaskType {
        return .google
    }
    
    override func sync() {
        print("[Sync Google] syncing...")
        
        if !appGoogleDrive.isDriveEnabled() {
            finish("[Sync Google] not logined")
            return
        }
        
        appGoogleDrive.lookupInRoot(filename: SyncGoogleDrive.NAME_SYNC) { (fileId, fileHash, error) in
            if error == .lookupError {
                self.finish("[Sync Google] failed sync!")
                return
            }
            
            if let hash = fileHash, hash == appSettings.googleSyncLastHash {
                print("[Sync Google] no need to import (cloud data hasn't changed)")
                self.upload(to: fileId, lastHash: hash)
                return
            }
            
            appGoogleDrive.downloadFile(fileid: fileId, completion: { (fileData, error) in
                if error == .downloadError {
                    self.finish("[Sync Google] failed to download sync data!")
                    return
                }
                
                if !appSettings.googleSyncMade {
                    DispatchQueue.main.async {
                        self.mergeAsk(data: fileData, fileId: fileId, lastHash: fileHash ?? "")
                    }
                    return
                }
                
                self.manager.importData(fileData, with: get_context())
                self.upload(to: fileId, lastHash: fileHash ?? "")
            })
        }
    }
    
    private func mergeAsk(data: Data?, fileId: String?, lastHash: String) {
        let alert = UIAlertController(title: nil, message: "SYNC_GOOGLE_MERGE_MSG".loc(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "MERGE".loc(), style: .default) { action in
            self.manager.importData(data, with: get_context())
            self.upload(to: fileId, lastHash: lastHash)
        })
        alert.addAction(UIAlertAction(title: "OVERWRITE".loc(), style: .destructive) { action in
            self.overwriteAsk(to: fileId, lastHash: lastHash)
        })
        
        top_view_controller()?.present(alert, animated: true)
    }
    
    private func overwriteAsk(to fileId: String?, lastHash: String) {
        let alert = UIAlertController(title: nil, message: "SYNC_GOOGLE_DELETE_MSG".loc(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "PROCEED".loc(), style: .default) { action in
            self.upload(to: fileId, lastHash: lastHash)
        })
        alert.addAction(UIAlertAction(title: "CANCEL".loc(), style: .cancel) { action in
            self.finish("[Sync Google] User canceled")
        })
        
        top_view_controller()?.present(alert, animated: true)
    }
    
    private func upload(to fileId: String?, lastHash: String) {
        guard let data = AppData().exportToData() else {
            self.finish("[Sync Google] failed to export data!")
            return
        }
        
        let curhash = AppData.getDataHash(data)
        if lastHash == curhash {
            print("[Sync Google] no need to upload (client data hasn't changed)")
            self.complete(true, withHash: curhash)
            return
        }
        
        print("[Sync Google] uploading...")
        
        if let fid = fileId {
            appGoogleDrive.updateFile(data: data, fileid: fid, filehash: curhash, mime: .binary) { (success) in
                self.complete(success, withHash: curhash)
            }
        }
        else {
            appGoogleDrive.uploadToRoot(data: data, filename: SyncGoogleDrive.NAME_SYNC, filehash: curhash, description: SyncGoogleDrive.DESC_SYNC, mime: .binary) { (success) in
                self.complete(success, withHash: curhash)
            }
        }
    }
    
    private func complete(_ success: Bool, withHash hash: String) {
        if success {
            appSettings.googleSyncLastHash = hash
            appSettings.googleSyncDate = Date()
            appSettings.googleSyncMade = true
            appSettings.save()
            
            DispatchQueue.main.async {
                SettingsViewController.view?.updateLabels()
            }
            
            finish("[Sync Google] ok.")
        }
        else {
            finish("[Sync Google] failed to upload sync base!")
        }
    }
}
