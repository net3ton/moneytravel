//
//  CurrencyExchange.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 24/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import Foundation
import UIKit

// fixer.io
// "https://www.exchange-rates.org/Rate/USD/UAH"
// "([0-9]+[.,])*[0-9]+ UAH"

class CurrencyExchangeRate {
    private static let REQUEST_URL = "https://www.exchange-rates.org/Rate/%@/%@"
    private static let REGEX = "([0-9]+[.,])*[0-9]+ %@"
    public static let RES_ERROR: Float = -1.0

    public static func fetch(fromIso: String, toIso: String, result: @escaping ((Float) -> Void)) {

        let urlStr = String(format: REQUEST_URL, fromIso, toIso)
        guard let url = URL(string: urlStr) else {
            print("Currence exchange: url is not valid!")
            result(self.RES_ERROR)
            return
        }

        let session = URLSession(configuration:.default)

        let task = session.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("Currence exchange: " + err.localizedDescription)
                result(self.RES_ERROR)
                return
            }
            
            guard let rdata = data else {
                print("Currence exchange: no data received!")
                result(self.RES_ERROR)
                return
            }
            
            print(String(format: "Currence exchange: %i data recevied.", rdata.count))
            
            guard let rstring = String(data: rdata, encoding: String.Encoding.utf8) else {
                print("Currence exchange: invalid data received!")
                result(self.RES_ERROR)
                return
            }
            
            do {
                let regex = try NSRegularExpression(pattern: String(format: self.REGEX, toIso))
                let res = regex.matches(in: rstring, range: NSRange(rstring.startIndex..., in: rstring))
                
                //for match in res {
                //    let r = Range(match.range, in: rstring)
                //    print(rstring[r!])
                //}
                
                if !res.isEmpty {
                    let rateSubstring = rstring[Range(res[0].range, in: rstring)!]
                    let rateString = String(rateSubstring.prefix(rateSubstring.count - 3))
                    print("Currence exchange: rate = " + rateSubstring)

                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.locale = Locale(identifier: "en_US")
                    
                    guard let rate = formatter.number(from: rateString) else {
                        print("Currence exchange: failed to get correct value from response!")
                        result(self.RES_ERROR)
                        return
                    }

                    result(rate.floatValue)
                    return
                }
            }
            catch let error {
                print("Currence exchange: invalid result format, " + error.localizedDescription)
                result(self.RES_ERROR)
                return
            }

            print("Currence exchange: exchange rate not found in response!")
            result(self.RES_ERROR)
        }
        
        task.resume()
    }

    public static func check() {
        if isNeedToUpdate() {
            update()
        }
    }

    public static func update() {
        if appSettings.currency == appSettings.currencyBase {
            appSettings.saveExchangeRate(val: 1.0)
            updateSettingsView()
            return
        }

        fetch(fromIso: appSettings.currencyBase, toIso: appSettings.currency, result: { rate in
            DispatchQueue.main.async {
                if (rate > 0) {
                    appSettings.saveExchangeRate(val: rate)
                }

                updateSettingsView()
            }
        })
    }

    private static func isNeedToUpdate() -> Bool {
        if !appSettings.exchangeUpdate {
            return false
        }

        if let date = appSettings.exchangeUpdateDate {
            return date.timeIntervalSinceNow < -(6 * 3600)
        }

        return true
    }

    private static func updateSettingsView() {
        if let settings = top_view_controller() as? SettingsViewController {
            settings.updateLabels()
        }
    }
}
