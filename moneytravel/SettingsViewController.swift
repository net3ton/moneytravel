//
//  SettingsViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var currencyBase: UILabel!
    @IBOutlet weak var dailyMax: UILabel!
    @IBOutlet weak var headerSince: UILabel!
    @IBOutlet weak var dayStartTime: UILabel!
    @IBOutlet weak var inputMul: UILabel!
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRate: UILabel!
    @IBOutlet weak var exchangeUpdate: UISwitch!
    @IBOutlet weak var exchangeUpdateLabel: UILabel!
    @IBOutlet weak var fractionCurrent: UISwitch!
    @IBOutlet weak var fractionBase: UISwitch!
    
    @IBOutlet weak var googleDriveLabel: UILabel!
    @IBOutlet weak var googleDriveSyncLabel: UILabel!
    
    @IBOutlet weak var icloudEnabled: UISwitch!
    @IBOutlet weak var icloudSyncLabel: UILabel!
    
    private var headerDateSince: HistoryDate = HistoryDate()

    override func viewDidLoad() {
        super.viewDidLoad()

        headerDateSince.setDate(appSettings.headerSince)
        updateLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appPurchases.fetchProducts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            appSettings.save()
        }
    }
    
    func updateLabels() {
        currency.text = appSettings.currency
        currencyBase.text = appSettings.currencyBase
        dailyMax.text = bsum_to_string(sum: appSettings.dailyMax)
        headerSince.text = headerDateSince.getName()
        inputMul.text = appSettings.inputMulStr ?? "none"

        exchangeRate.text = String.init(format: "%@ %@", num_to_string(sum: appSettings.exchangeRate, fraction: 2), appSettings.currency)
        exchangeUpdate.isOn = appSettings.exchangeUpdate
        exchangeRateLabel.text = String(format: "1 %@ =", appSettings.currencyBase)
        exchangeUpdateLabel.text = getLastCurrencyExchangeRateUpdateString()
        fractionCurrent.isOn = appSettings.fractionCurrent
        fractionBase.isOn = appSettings.fractionBase

        icloudEnabled.isOn = appSettings.icloudSyncEnabled
        icloudSyncLabel.text = getLastSyncString(appSettings.icloudSyncDate)
        googleDriveLabel.text = appGoogleDrive.isLogined() ? "Sign out" : "Sign in"
        googleDriveSyncLabel.text = getLastSyncString(appSettings.googleSyncDate)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        dayStartTime.text = formatter.string(from: appSettings.dayStartTime)
    }

    private func deselectAll() {
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
    
    private func getLastCurrencyExchangeRateUpdateString() -> String {
        guard let date = appSettings.exchangeUpdateDate else {
            return "Last update: never"
        }

        if date.timeIntervalSince1970 == 0 {
            return "Last update: manual set"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yyyy"
        return String.init(format: "Last update: %@", formatter.string(from: date))
    }

    private func getLastSyncString(_ syncDate: Date?) -> String {
        guard let date = syncDate else {
            return "Last sync: never"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yyyy"
        return String.init(format: "Last sync: %@", formatter.string(from: date))
    }

    @IBAction func currencyUpdateCheck(_ sender: UISwitch) {
        appSettings.exchangeUpdate = sender.isOn
        if appSettings.exchangeUpdate {
            CurrencyExchangeRate.update()
        }
    }

    @IBAction func fractionCurrentCheck(_ sender: UISwitch) {
        appSettings.fractionCurrent = sender.isOn
        updateLabels()
    }

    @IBAction func fractionBaseCheck(_ sender: UISwitch) {
        appSettings.fractionBase = sender.isOn
        updateLabels()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 && indexPath.row == 1 {
            if appGoogleDrive.isLogined() {
                
                let msg = UIAlertController(title: "Sign out from Google Drive", message: "This operation will disable sync with Google Drive.", preferredStyle: .alert)
                msg.addAction(UIAlertAction(title: "Proceed", style: .default) { (action) in
                    appGoogleDrive.signOut() {
                        self.updateLabels()
                    }
                })
                msg.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(msg, animated: true) {
                    self.deselectAll()
                }
            }
            else {
                appGoogleDrive.signIn(vc: self) {
                    self.updateLabels()
                }
            }
        }
    }
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "currency" {
            let currencyPicker = segue.destination as! CurrenciesViewController
            currencyPicker.selectedHandler = { iso in
                appSettings.currency = iso
                self.updateLabels()
                CurrencyExchangeRate.update()
            }
        }
        else if segue.identifier == "currency-base" {
            let currencyPicker = segue.destination as! CurrenciesViewController
            currencyPicker.selectedHandler = { iso in
                appSettings.currencyBase = iso
                self.updateLabels()
                CurrencyExchangeRate.update()
            }
        }
        else if segue.identifier == "header-since" {
            let datePicker = segue.destination as! DateStampViewController
            datePicker.setup(forDate: headerDateSince, min: nil, max: Date())
            datePicker.onDatePicked = { hdate in
                appSettings.headerSince = hdate.getDate()
                self.updateLabels()
            }
        }
        else if segue.identifier == "daily-max" {
            let sumEdit = segue.destination as! SumViewController
            sumEdit.setup(caption: "Daily budget", sum: appSettings.dailyMax, currency: appSettings.currencyBase)
            sumEdit.onSumEntered = { val in
                appSettings.dailyMax = val
                self.updateLabels()
            }
        }
        else if segue.identifier == "exchange-rate" {
            let sumEdit = segue.destination as! SumViewController
            sumEdit.setup(caption: "Exchange rate", sum: appSettings.exchangeRate, currency: appSettings.currency)
            sumEdit.onSumEntered = { val in
                appSettings.exchangeRate = val
                appSettings.exchangeUpdate = false
                appSettings.exchangeUpdateDate = Date(timeIntervalSince1970: 0)
                self.updateLabels()
            }
        }
        else if segue.identifier == "input-mul" {
            let mulEdit = segue.destination as! SumViewController
            mulEdit.setup(caption: "Input multiplier", sum: Float(appSettings.inputMul), currency: nil, fraction: false)
            mulEdit.onSumEntered = { val in
                appSettings.inputMul = Int(val)
                self.updateLabels()
            }
        }
        else if segue.identifier == "day-start" {
            let timePicker = segue.destination as! DateViewController
            timePicker.setup(caption: "Day start time", date: appSettings.dayStartTime, timeOnly: true)
            timePicker.onDatePicked = { val in
                let minutes = Calendar.current.component(.minute, from: val)
                let hours = Calendar.current.component(.hour, from: val)
                appSettings.dayStart = hours * 3600 + minutes * 60
                self.updateLabels()
            }
        }
    }
}
