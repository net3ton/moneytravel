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
    var icloudSyncLastHash: String = ""
    var icloudSyncMade: Bool = false
    
    var googleSyncDate: Date?
    var googleSyncLastHash: String = ""
    var googleSyncMade: Bool = false
    
    var initDate: Date = Date()
    var ratemeDone: Bool = false
    
    let local = UserDefaults.standard
    let cloud = NSUbiquitousKeyValueStore()
    
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
        static let ICLOUD_SYNC_HASH = "icloud-sync-hash"
        static let ICLOUD_SYNC_MADE = "icloud-sync-made"
        
        static let GOOGLE_SYNC_DATE = "google-sync-date"
        static let GOOGLE_SYNC_HASH = "google-sync-hash"
        static let GOOGLE_SYNC_MADE = "google-sync-made"
        
        static let INIT_DATE = "init-date"
        static let RATEME_DONE = "rateme-done"
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
        dailyMax = loadValue(forKey: ConfNames.DAILY_MAX, def: ConfDefaults.DAILY_MAX)
        headerSince = loadValue(forKey: ConfNames.HEADER_SINCE, def: ConfDefaults.HEADER_SINCE)
        dayStart = loadValue(forKey: ConfNames.DAY_START, def: ConfDefaults.DAY_START)
        inputMul = loadValue(forKey: ConfNames.INPUT_MUL, def: ConfDefaults.INPUT_MUL)
        
        currency = loadValue(forKey: ConfNames.CURRENCY, def: ConfDefaults.CURRENCY)
        currencyBase = loadValue(forKey: ConfNames.CURRENCY_BASE, def: ConfDefaults.CURRENCY_BASE)

        exchangeRate = loadValue(forKey: ConfNames.EXCHANGE_RATE, def: ConfDefaults.EXCHANGE_RATE)
        exchangeUpdate = loadValue(forKey: ConfNames.EXCHANGE_UPDATE, def: ConfDefaults.EXCHANGE_UPDATE)

        fractionCurrent = loadValue(forKey: ConfNames.FRACTION_CURRENT, def: ConfDefaults.FRACTION_CURRENT)
        fractionBase = loadValue(forKey: ConfNames.FRACTION_BASE, def: ConfDefaults.FRACTION_BASE)
        
        // local only
        exchangeUpdateDate = local.object(forKey: ConfNames.EXCHANGE_UPDATE_DATE) as? Date
    
        budgetTotal = local.object(forKey: ConfNames.BUDGET_TOTAL) as? Bool ?? ConfDefaults.BUDGET_TOTAL
        
        icloudSyncEnabled = local.object(forKey: ConfNames.ICLOUD_SYNC_ENABLED) as? Bool ?? ConfDefaults.ICLOUD_SYNC_ENABLED
        icloudSyncDate = local.object(forKey: ConfNames.ICLOUD_SYNC_DATE) as? Date
        icloudSyncLastHash = local.object(forKey: ConfNames.ICLOUD_SYNC_HASH) as? String ?? ""
        icloudSyncMade = local.object(forKey: ConfNames.ICLOUD_SYNC_MADE) as? Bool ?? false
        
        googleSyncDate = local.object(forKey: ConfNames.GOOGLE_SYNC_DATE) as? Date
        googleSyncLastHash = local.object(forKey: ConfNames.GOOGLE_SYNC_HASH) as? String ?? ""
        googleSyncMade = local.object(forKey: ConfNames.GOOGLE_SYNC_MADE) as? Bool ?? false
        
        initDate = local.object(forKey: ConfNames.INIT_DATE) as? Date ?? Date()
        ratemeDone = local.object(forKey: ConfNames.RATEME_DONE) as? Bool ?? false
    }

    func save() {
        saveValue(dailyMax, forKey: ConfNames.DAILY_MAX)
        saveValue(headerSince, forKey: ConfNames.HEADER_SINCE)
        saveValue(dayStart, forKey: ConfNames.DAY_START)
        saveValue(inputMul, forKey: ConfNames.INPUT_MUL)

        saveValue(currency, forKey: ConfNames.CURRENCY)
        saveValue(currencyBase, forKey: ConfNames.CURRENCY_BASE)

        saveValue(exchangeRate, forKey: ConfNames.EXCHANGE_RATE)
        saveValue(exchangeUpdate, forKey: ConfNames.EXCHANGE_UPDATE)

        saveValue(fractionCurrent, forKey: ConfNames.FRACTION_CURRENT)
        saveValue(fractionBase, forKey: ConfNames.FRACTION_BASE)
        
        // local only
        local.set(exchangeUpdateDate, forKey: ConfNames.EXCHANGE_UPDATE_DATE)
        
        local.set(budgetTotal, forKey: ConfNames.BUDGET_TOTAL)
        
        local.set(icloudSyncEnabled, forKey: ConfNames.ICLOUD_SYNC_ENABLED)
        local.set(icloudSyncDate, forKey: ConfNames.ICLOUD_SYNC_DATE)
        local.set(icloudSyncLastHash, forKey: ConfNames.ICLOUD_SYNC_HASH)
        local.set(icloudSyncMade, forKey: ConfNames.ICLOUD_SYNC_MADE)
        
        local.set(googleSyncDate, forKey: ConfNames.GOOGLE_SYNC_DATE)
        local.set(googleSyncLastHash, forKey: ConfNames.GOOGLE_SYNC_HASH)
        local.set(googleSyncMade, forKey: ConfNames.GOOGLE_SYNC_MADE)

        local.set(initDate, forKey: ConfNames.INIT_DATE)
        local.set(ratemeDone, forKey: ConfNames.RATEME_DONE)
        
        cloud.synchronize()
        print("settings saved.")
    }

    private func loadValue<T>(forKey key: String, def: T) -> T {
        return cloud.object(forKey: key) as? T ?? (local.object(forKey: key) as? T ?? def)
    }
    
    private func saveValue<T>(_ value: T, forKey key: String) {
        cloud.set(value, forKey: key)
        local.set(value, forKey: key)
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

    func isICloudEnabled() -> Bool {
        return icloudSyncEnabled && appICloudDrive.isEnabled()
    }
}

let appSettings = AppSettings()
