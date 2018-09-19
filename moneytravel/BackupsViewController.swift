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
            appSettings.googleSyncLastHash = ""
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
            
            if let appdata = AppData.loadFromData(data) {
                appdata.importData(with: get_context())
                
                DispatchQueue.main.async {
                    appCategories.reload()
                    lastSpends.reload()
                    
                    let main = top_view_controller() as? MainViewController
                    main?.updateSpendsView()
                }
            }
        }
        catch let error {
            print("Failed to import! ERROR: " + error.localizedDescription)
        }
    }
    
    private func deselectAll() {
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
}
