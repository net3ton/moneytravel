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
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var exchangeRate: UILabel!
    @IBOutlet weak var exchangeUpdate: UISwitch!
    @IBOutlet weak var exchangeUpdateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        if needToUpdateCurrencyExchangeRate() {
            updateCurrenciesRate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateLabels() {
        currency.text = appSettings.currency
        currencyBase.text = appSettings.currencyBase
        dailyMax.text = sum_to_string(sum: appSettings.dailyMax, currency: appSettings.currencyBase)

        exchangeRate.text = sum_to_string(sum: appSettings.exchangeRate, currency: appSettings.currency)
        exchangeUpdate.isOn = appSettings.exchangeUpdate
        exchangeRateLabel.text = String(format: "1 %@ =", appSettings.currencyBase)
        exchangeUpdateLabel.text = getLastCurrencyExchangeRateUpdateString()
    }

    func updateCurrenciesRate() {
        if appSettings.currency == appSettings.currencyBase {
            appSettings.exchangeRate = 1.0
            self.updateLabels()
            return
        }
        
        CurrencyExchangeRate.fetch(fromIso: appSettings.currencyBase, toIso: appSettings.currency, result: { rate in
            if (rate > 0) {
                appSettings.exchangeRate = rate
                self.stampCurrencyExchangeRateUpdate()

                DispatchQueue.main.async {
                    self.updateLabels()
                }
            }
        })
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

    private func needToUpdateCurrencyExchangeRate() -> Bool {
        if !appSettings.exchangeUpdate {
            return false
        }

        guard let date = appSettings.exchangeUpdateDate else {
            return true
        }
        
        return date.timeIntervalSinceNow > (6 * 3600)
    }

    private func stampCurrencyExchangeRateUpdate() {
        appSettings.exchangeUpdateDate = Date()
    }

    private func makePopupFloat(title: String, value: Float, resultcb: @escaping ((Float) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = String(format: "%.02f", value)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let textfield = alert.textFields?.first
            if let dailyMax = Float(textfield?.text ?? "") {
                resultcb(dailyMax)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            let dailyMaxPopup = makePopupFloat(title: "Daily Limit", value: appSettings.dailyMax, resultcb: { val in
                appSettings.dailyMax = val
                self.updateLabels()
            })
            
            present(dailyMaxPopup, animated: true, completion: {
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            if appSettings.currency == appSettings.currencyBase {
                return
            }
            
            let title = String(format: "Exchange Rate for %@", appSettings.currency)
            let exchangeRatePopup = makePopupFloat(title: title, value: appSettings.exchangeRate, resultcb: { val in
                appSettings.exchangeRate = val
                appSettings.exchangeUpdate = false
                appSettings.exchangeUpdateDate = Date(timeIntervalSince1970: 0)
                self.updateLabels()
            })
            
            present(exchangeRatePopup, animated: true, completion: {
                tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    @IBAction func currencyUpdateCheck(_ sender: UISwitch) {
        appSettings.exchangeUpdate = sender.isOn
        if appSettings.exchangeUpdate {
            self.updateCurrenciesRate()
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
                self.updateCurrenciesRate()
            }
        }

        if segue.identifier == "currency-base" {
            let currencyPicker = segue.destination as! CurrenciesViewController
            currencyPicker.selectedHandler = { iso in
                appSettings.currencyBase = iso
                self.updateLabels()
                self.updateCurrenciesRate()
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
