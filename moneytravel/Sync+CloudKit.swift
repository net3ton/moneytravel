//
//  Sync+CloudKit.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 14/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

extension AppSync {
    private static let REC_TYPE = "MoneyTravelSync3"
    private static let REC_ID = CKRecord.ID(recordName: "moneytravel-sync-id6")
    
    public func makeICloudSync() {
        print("[Sync iCloud] syncing...")
        icloudToSync = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        
        let context = get_context()
        let container = CKContainer.default().privateCloudDatabase
        let operation = CKFetchRecordsOperation(recordIDs: [AppSync.REC_ID])
        
        operation.fetchRecordsCompletionBlock = { (records, error) in
            if let ckerror = error as? CKError {
                if ckerror.code != CKError.Code.partialFailure {
                    print("[Sync iCloud] Failed to get record info! ERROR: " + ckerror.localizedDescription)
                    return
                }
                
                print("[Sync iCloud] record info not found")
                self.iCloudUpload(container, record: nil, recHash: "", with: context)
                return
            }
            
            let rec = records?[AppSync.REC_ID]
            let hash = rec?["hash"] as? String ?? ""
            
            if hash == appSettings.icloudSyncLastHash {
                print("[Sync iCloud] no need to import (cloud data hasn't changed)")
                self.iCloudUpload(container, record: rec, recHash: hash, with: context)
                return
            }
            
            self.iCloudImport(container, recHash: hash, with: context)
        }
        
        operation.desiredKeys = ["hash"]
        operation.timeoutIntervalForResource = TimeInterval(15)
        container.add(operation)
    }

    private func iCloudImport(_ container: CKDatabase, recHash: String, with context: NSManagedObjectContext) {
        print("[Sync iCloud] loading...")
        
        container.fetch(withRecordID: AppSync.REC_ID) { (record, error) in
            if let ckerror = error as? CKError {
                if ckerror.code != CKError.Code.unknownItem {
                    print("[Sync iCloud] Failed to get record! ERROR: " + ckerror.localizedDescription)
                    return
                }
                
                print("[Sync iCloud] record not found")
            }
            
            if let record = record {
                let fileData = record["data"] as? Data
                self.importData(fileData, with: context)
            }
            
            self.iCloudUpload(container, record: record, recHash: recHash, with: context)
        }
    }

    private func iCloudUpload(_ container: CKDatabase, record: CKRecord?, recHash: String, with context: NSManagedObjectContext) {
        guard let data = AppData(with: context).exportToData() else {
            print("[Sync iCloud] failed to export data!")
            return
        }
        
        let curHash = AppData.getDataHash(data)
        if recHash == curHash {
            print("[Sync iCloud] no need to upload (client data hasn't changed)")
            self.iCloudComplete(withHash: curHash)
            return
        }
        
        print("[Sync iCloud] saving...")
        
        let rec = (record != nil) ? record! : CKRecord(recordType: AppSync.REC_TYPE, recordID: AppSync.REC_ID)
        
        rec["data"] = data as CKRecordValue
        rec["hash"] = curHash as CKRecordValue
        
        container.save(rec) { (record, error) in
            if let error = error {
                print("[Sync iCloud] Failed to save record! ERROR: " + error.localizedDescription)
                return
            }
            
            self.iCloudComplete(withHash: curHash)
        }
    }
    
    private func iCloudComplete(withHash hash: String) {
        self.icloudToSync = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        appSettings.icloudSyncLastHash = hash
        appSettings.icloudSyncDate = Date()
        appSettings.save()
        print("[Sync iCloud] ok.")
        
        DispatchQueue.main.async {
            SettingsViewController.view?.updateLabels()
        }
    }
}
