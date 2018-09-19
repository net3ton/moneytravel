//
//  BackupCreateViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class BackupCreateViewController: UITableViewController {
    @IBOutlet weak var switchAllData: UISwitch!
    @IBOutlet weak var backupName: UILabel!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var labelTo: UILabel!
    
    private var interval = HistoryInterval()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "BACKUP".loc()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CREATE".loc(), style: .plain, target: self, action: #selector(createBackup))
        
        backupName.text = "MoneyTravel.backup"
        
        interval.dateFrom.setWeekAgo()
        interval.dateTo.setToday()
        
        updateIntervalInfo()
    }
    
    private func updateIntervalInfo() {
        labelFrom.text = interval.dateFrom.getName()
        labelTo.text = interval.dateTo.getName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = backupName.text ?? ""
        navigationItem.rightBarButtonItem?.isEnabled = !name.isEmpty
    }
    
    @IBAction func onSwitchInterval(_ sender: UISwitch) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && switchAllData.isOn {
            return 1
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    private func getBackupData() -> Data? {
        if switchAllData.isOn {
            return AppData().exportToData()
        }
        
        let backupHistory = appSpends.fetch(for: interval)
        return AppData(history: backupHistory).exportToData()
    }
    
    @objc private func createBackup() {
        guard let data = getBackupData() else {
            showBackupMessage("EXPORT_ERROR".loc())
            return
        }
        
        guard let name = backupName.text, let path = get_temp_path()?.appendingPathComponent(name) else {
            showBackupMessage("EXPORT_ERROR".loc())
            return
        }
        
        guard data.saveTo(path) else {
            showBackupMessage("EXPORT_ERROR".loc())
            return
        }
        
        let panel = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        present(panel, animated: true)
    }
    
    private func showBackupMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".loc(), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backup-name" {
            let nameEdit = segue.destination as! TextViewController
            nameEdit.setup(caption: "NAME".loc(), text: backupName.text ?? "")
            nameEdit.onTextEntered = { text in
                self.backupName.text = text
            }
        }
        else if segue.identifier == "backup-from" {
            let dateEdit = segue.destination as! DateStampViewController
            dateEdit.setup(forDate: interval.dateFrom, min: nil, max: interval.dateTo.getDate())
            dateEdit.onDatePicked = { date in
                self.interval.dateFrom = date
                self.updateIntervalInfo()
            }
        }
        else if segue.identifier == "backup-to" {
            let dateEdit = segue.destination as! DateStampViewController
            dateEdit.setup(forDate: interval.dateTo, min: interval.dateFrom.getDate(), max: nil)
            dateEdit.onDatePicked = { date in
                self.interval.dateTo = date
                self.updateIntervalInfo()
            }
        }
    }
}
