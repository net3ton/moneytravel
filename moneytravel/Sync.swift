//
//  Sync.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

enum SyncTaskType {
    case unknown
    case icloud
    case google
}

class SyncTask {
    internal weak var manager: AppSync!
    
    init(_ manager: AppSync) {
        self.manager = manager
    }
    
    internal func finish(_ msg: String)  {
        print(msg)
        manager.taskFinished(type: type)
    }
    
    open func sync() {}
    open var type: SyncTaskType { return .unknown }
}


let appSync = AppSync()

class AppSync {
    private var lastSync = Date()
    private var tasks: [SyncTask] = []
    
    public func sync() {
        if lastSync > Date() {
            return
        }
        
        lastSync = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        
        syncICloud()
        syncGoogle()
    }
    
    public func resetDelay() {
        lastSync = Date()
    }
    
    public func syncICloud() {
        if !taskInQueue(.icloud) {
            syncTask(SyncICloud(self))
        }
    }
    
    public func syncGoogle() {
        if !taskInQueue(.google) {
            syncTask(SyncGoogleDrive(self))
        }
    }
    
    private func syncTask(_ task: SyncTask) {
        tasks.append(task)
        
        if tasks.count == 1 {
            tasks[0].sync()
        }
    }
    
    private func taskInQueue(_ type: SyncTaskType) -> Bool {
        return tasks.first { (task) -> Bool in
            return task.type == type
        } != nil
    }

    public func taskFinished(type: SyncTaskType) {
        print("TASK FINISHED")
        
        tasks.removeAll { (task) -> Bool in
            task.type == type
        }
        
        tasks.last?.sync()
    }
    
    public func importData(_ data: Data?, with context: NSManagedObjectContext) {
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
