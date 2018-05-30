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
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let dailyMaxStr = formatter.string(from: NSNumber(value: appSettings.dailyMax))
        
        currency.text = appSettings.currency
        currencyBase.text = appSettings.currencyBase
        dailyMax.text = String(format: "%@ %@", dailyMaxStr!, appSettings.currencyBase)
        
        let exchangeRateStr = formatter.string(from: NSNumber(value: appSettings.exchangeRate))
        
        exchangeRate.text = exchangeRateStr
        exchangeUpdate.isOn = appSettings.exchangeUpdate
        exchangeRateLabel.text = String(format: "1 %@ = %@ %@", appSettings.currencyBase, exchangeRateStr!, appSettings.currency)

        //tableView.footerView(forSection: 1)?.textLabel?.text = "ha ha ha"
    }

    func updateCurrenciesRate() {
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
        formatter.dateFormat = "Last update: dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }

    private func needToUpdateCurrencyExchangeRate() -> Bool {
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
    
    /*
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height: 40))
        footerView.backgroundColor = UIColor.lightGray
        
        switch(section) {
        case 1: // change only 3rd cell's footer
            let label = UILabel(frame: footerView.frame)
            label.text = "Section 5"
            footerView.addSubview(label)
            return footerView
        default: break
        }
        return nil
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParentViewController {
            appSettings.save()
        }
    }
}
