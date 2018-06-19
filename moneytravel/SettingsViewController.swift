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
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRate: UILabel!
    @IBOutlet weak var exchangeUpdate: UISwitch!
    @IBOutlet weak var exchangeUpdateLabel: UILabel!

    private var headerDateSince: HistoryDate = HistoryDate()

    override func viewDidLoad() {
        super.viewDidLoad()

        headerDateSince.setDate(date: appSettings.headerSince)
        updateLabels()
    }

    //override func viewWillAppear(_ animated: Bool) {
    //    super.viewWillAppear(animated)
    //}

    func updateLabels() {
        currency.text = appSettings.currency
        currencyBase.text = appSettings.currencyBase
        dailyMax.text = sum_to_string(sum: appSettings.dailyMax, currency: appSettings.currencyBase)
        headerSince.text = headerDateSince.getName()

        exchangeRate.text = sum_to_string(sum: appSettings.exchangeRate, currency: appSettings.currency)
        exchangeUpdate.isOn = appSettings.exchangeUpdate
        exchangeRateLabel.text = String(format: "1 %@ =", appSettings.currencyBase)
        exchangeUpdateLabel.text = getLastCurrencyExchangeRateUpdateString()
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

    @IBAction func currencyUpdateCheck(_ sender: UISwitch) {
        appSettings.exchangeUpdate = sender.isOn
        if appSettings.exchangeUpdate {
            CurrencyExchangeRate.update()
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
            let datePicker = segue.destination as! DateMarkViewController
            datePicker.setup(forDate: headerDateSince, min: nil, max: Date())
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParentViewController {
            appSettings.save()
        }
    }
}
