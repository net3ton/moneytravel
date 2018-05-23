//
//  Settings.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

enum EPasscodeType: Int {
    case none = 0
    case pin4 = 1
}

class AppSettings {
    var currency: String = ConfDefaults.CURRENCY
    var currencyBase: String = ConfDefaults.CURRENCY_BASE

    var dailyMax: Float = ConfDefaults.DAILY_MAX

    struct ConfNames {
        static let CURRENCY = "currency"
        static let CURRENCY_BASE = "currency-base"
        
        static let DAILY_MAX = "daily-max"
    }
    
    struct ConfDefaults {
        static let CURRENCY: String = "RUB"
        static let CURRENCY_BASE: String = "USD"

        static let DAILY_MAX: Float = 30.0
    }
    
    func load() {
        let conf = UserDefaults.standard
        
        currency = conf.object(forKey: ConfNames.CURRENCY) as? String ?? ConfDefaults.CURRENCY
        currencyBase = conf.object(forKey: ConfNames.CURRENCY_BASE) as? String ?? ConfDefaults.CURRENCY_BASE
        
        dailyMax = conf.object(forKey: ConfNames.DAILY_MAX) as? Float ?? ConfDefaults.DAILY_MAX
    }
    
    func save() {
        let conf = UserDefaults.standard
        
        conf.set(currency, forKey: ConfNames.CURRENCY)
        conf.set(currencyBase, forKey: ConfNames.CURRENCY_BASE)
        
        conf.set(dailyMax, forKey: ConfNames.DAILY_MAX)
    }
}

let appSettings = AppSettings()
