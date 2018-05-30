//
//  Settings.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class AppSettings {
    var currency: String = ConfDefaults.CURRENCY
    var currencyBase: String = ConfDefaults.CURRENCY_BASE
    var dailyMax: Float = ConfDefaults.DAILY_MAX
    
    var exchangeRate: Float = ConfDefaults.EXCHANGE_RATE
    var exchangeUpdate: Bool = ConfDefaults.EXCHANGE_UPDATE
    var exchangeUpdateDate: Date?

    struct ConfNames {
        static let CURRENCY = "currency"
        static let CURRENCY_BASE = "currency-base"
        static let DAILY_MAX = "daily-max"

        static let EXCHANGE_RATE = "exchange-rate"
        static let EXCHANGE_UPDATE = "exchange-update"
        static let EXCHANGE_UPDATE_DATE = "exchange-update-date"
    }
    
    struct ConfDefaults {
        static let CURRENCY: String = "RUB"
        static let CURRENCY_BASE: String = "USD"
        static let DAILY_MAX: Float = 30.0

        static let EXCHANGE_RATE: Float = 1.0
        static let EXCHANGE_UPDATE: Bool = true
    }
    
    func load() {
        let conf = UserDefaults.standard
        
        currency = conf.object(forKey: ConfNames.CURRENCY) as? String ?? ConfDefaults.CURRENCY
        currencyBase = conf.object(forKey: ConfNames.CURRENCY_BASE) as? String ?? ConfDefaults.CURRENCY_BASE
        dailyMax = conf.object(forKey: ConfNames.DAILY_MAX) as? Float ?? ConfDefaults.DAILY_MAX

        exchangeRate = conf.object(forKey: ConfNames.EXCHANGE_RATE) as? Float ?? ConfDefaults.EXCHANGE_RATE
        exchangeUpdate = conf.object(forKey: ConfNames.EXCHANGE_UPDATE) as? Bool ?? ConfDefaults.EXCHANGE_UPDATE
        exchangeUpdateDate = conf.object(forKey: ConfNames.EXCHANGE_UPDATE_DATE) as? Date
    }

    func save() {
        let conf = UserDefaults.standard
        
        conf.set(currency, forKey: ConfNames.CURRENCY)
        conf.set(currencyBase, forKey: ConfNames.CURRENCY_BASE)
        conf.set(dailyMax, forKey: ConfNames.DAILY_MAX)

        conf.set(exchangeRate, forKey: ConfNames.EXCHANGE_RATE)
        conf.set(exchangeUpdate, forKey: ConfNames.EXCHANGE_UPDATE)
        conf.set(exchangeUpdateDate, forKey: ConfNames.EXCHANGE_UPDATE_DATE)

        print("settings saved.")
    }
}

let appSettings = AppSettings()
