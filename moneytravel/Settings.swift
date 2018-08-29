//
//  Settings.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class AppSettings {
    var dailyMax: Float = ConfDefaults.DAILY_MAX
    var headerSince: Date = ConfDefaults.HEADER_SINCE
    var dayStart: Int = ConfDefaults.DAY_START
    {
        didSet {
            if dayStart < 0 {
                dayStart = 0
            }
            else if dayStart >= (24 * 3600) {
                dayStart = (24 * 3600) - 300
            }
        }
    }

    var inputMul: Int = ConfDefaults.INPUT_MUL
    {
        didSet {
            inputMul = max(inputMul, 1)
        }
    }

    var currency: String = ConfDefaults.CURRENCY
    var currencyBase: String = ConfDefaults.CURRENCY_BASE
    
    var exchangeRate: Float = ConfDefaults.EXCHANGE_RATE
    var exchangeUpdate: Bool = ConfDefaults.EXCHANGE_UPDATE
    var exchangeUpdateDate: Date?

    var fractionCurrent: Bool = ConfDefaults.FRACTION_CURRENT
    var fractionBase: Bool = ConfDefaults.FRACTION_BASE
    
    var budgetTotal: Bool = ConfDefaults.BUDGET_TOTAL
    
    var icloudSyncEnabled: Bool = ConfDefaults.ICLOUD_SYNC_ENABLED
    var icloudSyncDate: Date?
    var googleSyncDate: Date?
    
    struct ConfNames {
        static let DAILY_MAX = "daily-max"
        static let HEADER_SINCE = "header-since"
        static let DAY_START = "day-start"
        static let INPUT_MUL = "input-mul"

        static let CURRENCY = "currency"
        static let CURRENCY_BASE = "currency-base"

        static let EXCHANGE_RATE = "exchange-rate"
        static let EXCHANGE_UPDATE = "exchange-update"
        static let EXCHANGE_UPDATE_DATE = "exchange-update-date"
        
        static let FRACTION_CURRENT = "fraction-current"
        static let FRACTION_BASE = "fraction-base"
        
        static let BUDGET_TOTAL = "budget-mode"
        
        static let ICLOUD_SYNC_ENABLED = "icloud-sync-enabled"
        static let ICLOUD_SYNC_DATE = "icloud-sync-date"
        static let GOOGLE_SYNC_DATE = "google-sync-date"
    }
    
    struct ConfDefaults {
        static let DAILY_MAX: Float = 30.0
        static let HEADER_SINCE: Date = Calendar.current.startOfDay(for: Date())
        static let DAY_START: Int = 0
        static let INPUT_MUL: Int = 1

        static let CURRENCY: String = "RUB"
        static let CURRENCY_BASE: String = "USD"

        static let EXCHANGE_RATE: Float = 1.0
        static let EXCHANGE_UPDATE: Bool = true

        static let FRACTION_CURRENT: Bool = true
        static let FRACTION_BASE: Bool = true
        
        static let BUDGET_TOTAL: Bool = true
        
        static let ICLOUD_SYNC_ENABLED: Bool = true
    }
    
    func load() {
        let conf = UserDefaults.standard
        
        dailyMax = conf.object(forKey: ConfNames.DAILY_MAX) as? Float ?? ConfDefaults.DAILY_MAX
        headerSince = conf.object(forKey: ConfNames.HEADER_SINCE) as? Date ?? ConfDefaults.HEADER_SINCE
        dayStart = conf.object(forKey: ConfNames.DAY_START) as? Int ?? ConfDefaults.DAY_START
        inputMul = conf.object(forKey: ConfNames.INPUT_MUL) as? Int ?? ConfDefaults.INPUT_MUL
        
        currency = conf.object(forKey: ConfNames.CURRENCY) as? String ?? ConfDefaults.CURRENCY
        currencyBase = conf.object(forKey: ConfNames.CURRENCY_BASE) as? String ?? ConfDefaults.CURRENCY_BASE

        exchangeRate = conf.object(forKey: ConfNames.EXCHANGE_RATE) as? Float ?? ConfDefaults.EXCHANGE_RATE
        exchangeUpdate = conf.object(forKey: ConfNames.EXCHANGE_UPDATE) as? Bool ?? ConfDefaults.EXCHANGE_UPDATE
        exchangeUpdateDate = conf.object(forKey: ConfNames.EXCHANGE_UPDATE_DATE) as? Date

        fractionCurrent = conf.object(forKey: ConfNames.FRACTION_CURRENT) as? Bool ?? ConfDefaults.FRACTION_CURRENT
        fractionBase = conf.object(forKey: ConfNames.FRACTION_BASE) as? Bool ?? ConfDefaults.FRACTION_BASE
        
        budgetTotal = conf.object(forKey: ConfNames.BUDGET_TOTAL) as? Bool ?? ConfDefaults.BUDGET_TOTAL
        
        icloudSyncEnabled = conf.object(forKey: ConfNames.ICLOUD_SYNC_ENABLED) as? Bool ?? ConfDefaults.ICLOUD_SYNC_ENABLED
        icloudSyncDate = conf.object(forKey: ConfNames.ICLOUD_SYNC_DATE) as? Date
        googleSyncDate = conf.object(forKey: ConfNames.GOOGLE_SYNC_DATE) as? Date
    }

    func save() {
        let conf = UserDefaults.standard
        
        conf.set(dailyMax, forKey: ConfNames.DAILY_MAX)
        conf.set(headerSince, forKey: ConfNames.HEADER_SINCE)
        conf.set(dayStart, forKey: ConfNames.DAY_START)
        conf.set(inputMul, forKey: ConfNames.INPUT_MUL)

        conf.set(currency, forKey: ConfNames.CURRENCY)
        conf.set(currencyBase, forKey: ConfNames.CURRENCY_BASE)

        conf.set(exchangeRate, forKey: ConfNames.EXCHANGE_RATE)
        conf.set(exchangeUpdate, forKey: ConfNames.EXCHANGE_UPDATE)
        conf.set(exchangeUpdateDate, forKey: ConfNames.EXCHANGE_UPDATE_DATE)

        conf.set(fractionCurrent, forKey: ConfNames.FRACTION_CURRENT)
        conf.set(fractionBase, forKey: ConfNames.FRACTION_BASE)
        
        conf.set(budgetTotal, forKey: ConfNames.BUDGET_TOTAL)
        
        conf.set(icloudSyncEnabled, forKey: ConfNames.ICLOUD_SYNC_ENABLED)
        conf.set(icloudSyncDate, forKey: ConfNames.ICLOUD_SYNC_DATE)
        conf.set(googleSyncDate, forKey: ConfNames.GOOGLE_SYNC_DATE)

        print("settings saved.")
    }

    func saveExchangeRate(val: Float) {
        exchangeRate = val
        exchangeUpdateDate = Date()
        save()
    }

    var inputMulStr: String? {
        if inputMul <= 1 {
            return nil
        }

        return num_to_string(sum: Float(inputMul), fraction: 0)
    }

    var dayStartTime: Date {
        let today = Calendar.current.startOfDay(for: Date())
        return today + TimeInterval(dayStart)
    }
}

let appSettings = AppSettings()
