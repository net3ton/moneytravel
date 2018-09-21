//
//  BackupsViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 15/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import MobileCoreServices

class BackupsViewController: UITableViewController, UIDocumentPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "BACKUPS".loc()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            loadBackup()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            resetAllData()
        }
    }
    
    private func resetAllData() {
        let msg = UIAlertController(title: nil, message: "DATA_RESET_MSG".loc(), preferredStyle: .actionSheet);
        
        msg.addAction(UIAlertAction(title: "DELETE".loc(), style: .destructive, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            
            reset_all_data()

            appSettings.icloudSyncLastHash = ""
            appSettings.icloudSyncMade = false
            appSettings.googleSyncLastHash = ""
            appSettings.googleSyncMade = false
            appSettings.save()
            
            appCategories.initCategories()
            appCategories.reload()
            lastSpends.reload()
        }))
        msg.addAction(UIAlertAction(title: "CANCEL".loc(), style: .cancel))
        
        present(msg, animated: true) {
            self.deselectAll()
        }
    }
    
    private func loadBackup() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import)
        importMenu.delegate = self
        //importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true) {
            self.deselectAll()
        }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.isEmpty {
            print("Document picker: nothing selected")
            return
        }
        
        do {
            let url = urls[0]
            let data = try Data(contentsOf: url)
            
            guard let appdata = AppData.loadFromData(data) else {
                throw NSError(domain: "Failed to load data", code: -1, userInfo: nil)
            }
            
            appdata.importData(with: get_context()) { cats, spends, tstams in
                var msg = "Imported:"
                
                if cats > 0 {
                    msg += String(format: " %i categories", cats)
                }
                if spends > 0 {
                    msg += String(format: " %i expenses", spends)
                }
                if spends > 0 {
                    msg += String(format: " %i timestamps", tstams)
                }
                
                self.showImportMessage(msg)
            }
            
            DispatchQueue.main.async {
                appCategories.reload()
                lastSpends.reload()
                
                let main = top_view_controller() as? MainViewController
                main?.updateSpendsView()
            }
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
            self.showImportMessage("IMPORT_ERROR".loc())
        }
    }
    
    private func showImportMessage(_ message: String) {
        show_info_message(self, msg: message) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func deselectAll() {
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
}
