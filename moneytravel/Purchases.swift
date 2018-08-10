//
//  Purchases.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 10/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import StoreKit

enum EPurchase: String {
    case donate1 = "com.oskharkov.moneytravel.donate1"
    case donate2 = "com.oskharkov.moneytravel.donate2"
    case donate3 = "com.oskharkov.moneytravel.donate3"
}

let appPurchases = AppPurchases()

class AppPurchases: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private var productRequest: SKProductsRequest?
    private var ids: [String] = []
    private var prods: [String: SKProduct] = [:]
    
    public var onPurchaseDone: ((EPurchase) -> Void)?
    
    override init() {
        super.init()
        
        addItem(.donate1)
        addItem(.donate2)
        addItem(.donate3)
        fetchProducts()
    }
    
    public func addItem(_ item: EPurchase) {
        ids.append(item.rawValue)
    }
    
    public func fetchProducts() {
        if prods.isEmpty && productRequest == nil {
            productRequest = SKProductsRequest(productIdentifiers: Set<String>(ids))
            productRequest?.delegate = self
            productRequest?.start()
        }
    }

    public func makePurchase(item: EPurchase) {
        if !SKPaymentQueue.canMakePayments() {
            return
        }

        if let prod = prods[item.rawValue] {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(SKPayment(product: prod))
        }
    }
    
    public func getProductPrice(item: EPurchase) -> String {
        if let prod = prods[item.rawValue] {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = prod.priceLocale
            
            return numberFormatter.string(from: prod.price) ?? ""
        }
        
        return ""
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            prods[product.productIdentifier] = product
        }
        
        productRequest = nil
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for trans in transactions {
            SKPaymentQueue.default().finishTransaction(trans)
            
            if trans.transactionState == .purchased {
                let productId = trans.payment.productIdentifier
                print("purchased:", productId)
                
                if let item = EPurchase(rawValue: productId) {
                    onPurchaseDone?(item)
                }
            }
        }
    }
}
