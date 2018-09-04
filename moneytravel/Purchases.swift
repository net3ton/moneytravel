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

class AppPurchases: NSObject, SKProductsRequestDelegate, SKRequestDelegate, SKPaymentTransactionObserver {
    private var productRequest: SKProductsRequest?
    private var ids: [String] = []
    private var prods: [String: SKProduct] = [:]
    
    public var onPurchaseDone: ((EPurchase) -> Void)?
    
    public func start() {
        print("[purchases] init")

        addItem(.donate1)
        addItem(.donate2)
        addItem(.donate3)

        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    private func addItem(_ item: EPurchase) {
        ids.append(item.rawValue)
    }
    
    public func fetchProducts() {
        if prods.isEmpty && productRequest == nil {
            print("[purchases] fetching products...")
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
            print("[purchases] purchase:", item.rawValue)
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
        for ids in response.invalidProductIdentifiers {
            print("[purchases] invalid ids:", ids)
        }
        
        for product in response.products {
            print("[purchases] ok ids:", product.productIdentifier)
            prods[product.productIdentifier] = product
        }
    }

    func requestDidFinish(_ request: SKRequest) {
        productRequest = nil
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("[purchases] " + error.localizedDescription)
        productRequest = nil
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for trans in transactions {
            if trans.transactionState == .purchased {
                let productId = trans.payment.productIdentifier
                print("[purchases] done:", productId)
                
                if let item = EPurchase(rawValue: productId) {
                    onPurchaseDone?(item)
                }
                
                SKPaymentQueue.default().finishTransaction(trans)
            }
            else if trans.transactionState == .failed {
                print("[purchases] failed:", trans.error?.localizedDescription ?? "")
                SKPaymentQueue.default().finishTransaction(trans)
            }
        }
    }
}
