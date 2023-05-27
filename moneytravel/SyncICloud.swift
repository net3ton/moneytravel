//
//  SyncCloud.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 21/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class SyncICloud: SyncTask {
    private static let REC_TYPE = "MoneyTravelSync"
    private static let REC_ID = CKRecord.ID(recordName: "moneytravel-sync-id")
    
    private let context = get_context()
    private let container = CKContainer.default().privateCloudDatabase
    
    override var type: SyncTaskType {
        return .icloud
    }
    
    override func sync() {
        print("[Sync iCloud] syncing...")
        
        if !appSettings.isICloudEnabled() {
            finish("[Sync iCloud] disabled.")
            return
        }
        
        let operation = CKFetchRecordsOperation(recordIDs: [SyncICloud.REC_ID])

        operation.fetchRecordsCompletionBlock = { (records, error) in
            if let ckerror = error as? CKError {
                if ckerror.code != CKError.Code.partialFailure {
                    self.finish("[Sync iCloud] Failed to get record info! ERROR: " + ckerror.localizedDescription)
                    return
                }
                
                print("[Sync iCloud] record info not found")
                self.upload(nil, recHash: "")
                return
            }
            
            let rec = records?[SyncICloud.REC_ID]
            let hash = rec?["hash"] as? String ?? ""
            
            if hash == appSettings.icloudSyncLastHash {
                print("[Sync iCloud] no need to import (cloud data hasn't changed)")
                self.upload(rec, recHash: hash)
                return
            }
            
            self.download(recHash: hash)
        }
        
        operation.desiredKeys = ["hash"]
        operation.configuration.timeoutIntervalForResource = TimeInterval(15)
        container.add(operation)
    }
    
    private func download(recHash: String) {
        print("[Sync iCloud] loading...")
        
        container.fetch(withRecordID: SyncICloud.REC_ID) { (record, error) in
            if let ckerror = error as? CKError {
                if ckerror.code != CKError.Code.unknownItem {
                    self.finish("[Sync iCloud] Failed to get record! ERROR: " + ckerror.localizedDescription)
                    return
                }
                
                print("[Sync iCloud] record not found")
            }
            
            if let record = record {
                if !appSettings.icloudSyncMade {
                    DispatchQueue.main.async {
                        self.mergeAsk(record, recHash: recHash)
                    }
                    return
                }
                
                self.importData(record)
            }
            
            self.upload(record, recHash: recHash)
        }
    }
    
    private func importData(_ record: CKRecord) {
        let fileData = record["data"] as? Data
        manager.importData(fileData, with: context)
    }
    
    private func mergeAsk(_ record: CKRecord, recHash: String) {
        let alert = UIAlertController(title: nil, message: "SYNC_ICLOUD_MERGE_MSG".loc(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "MERGE".loc(), style: .default) { action in
            self.importData(record)
            self.upload(record, recHash: recHash)
        })
        alert.addAction(UIAlertAction(title: "OVERWRITE".loc(), style: .destructive) { action in
            self.overwriteAsk(record, recHash: recHash)
        })
        
        top_view_controller()?.present(alert, animated: true)
    }
    
    private func overwriteAsk(_ record: CKRecord, recHash: String) {
        let alert = UIAlertController(title: nil, message: "SYNC_ICLOUD_DELETE_MSG".loc(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "PROCEED".loc(), style: .default) { action in
            self.upload(record, recHash: recHash)
        })
        alert.addAction(UIAlertAction(title: "CANCEL".loc(), style: .cancel) { action in
            self.finish("[Sync iCloud] User canceled")
        })
        
        top_view_controller()?.present(alert, animated: true)
    }
    
    private func upload(_ record: CKRecord?, recHash: String) {
        guard let data = AppData(with: context).exportToData() else {
            self.finish("[Sync iCloud] failed to export data!")
            return
        }
        
        let curHash = AppData.getDataHash(data)
        if curHash == recHash {
            print("[Sync iCloud] no need to upload (client data hasn't changed)")
            self.complete(withHash: curHash)
            return
        }
        
        print("[Sync iCloud] saving...")
        
        let rec = (record != nil) ? record! : CKRecord(recordType: SyncICloud.REC_TYPE, recordID: SyncICloud.REC_ID)
        
        rec["data"] = data as CKRecordValue
        rec["hash"] = curHash as CKRecordValue
        
        container.save(rec) { (record, error) in
            if let error = error {
                self.finish("[Sync iCloud] Failed to save record! ERROR: " + error.localizedDescription)
                return
            }
            
            self.complete(withHash: curHash)
        }
    }
    
    private func complete(withHash hash: String) {
        appSettings.icloudSyncLastHash = hash
        appSettings.icloudSyncDate = Date()
        appSettings.icloudSyncMade = true
        appSettings.save()
        
        DispatchQueue.main.async {
            SettingsViewController.view?.updateLabels()
        }
        
        finish("[Sync iCloud] ok.")
    }
}
