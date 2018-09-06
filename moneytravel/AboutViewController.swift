//
//  AboutViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 17/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import StoreKit

class AboutViewController: UIViewController {
    @IBOutlet weak var buttonDonate1: DonateButton!
    @IBOutlet weak var buttonDonate2: DonateButton!
    @IBOutlet weak var buttonDonate3: DonateButton!
    @IBOutlet weak var buttonRate: DonateButton!
    @IBOutlet weak var textAbout: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonDonate1.price = appPurchases.getProductPrice(item: .donate1)
        buttonDonate2.price = appPurchases.getProductPrice(item: .donate2)
        buttonDonate3.price = appPurchases.getProductPrice(item: .donate3)
        
        textAbout.text = "ABOUT".loc()
        textAbout.sizeToFit()
        textAbout.isScrollEnabled = false
    }

    @IBAction func onDonate1(_ sender: DonateButton) {
        appPurchases.makePurchase(item: .donate1)
    }

    @IBAction func onDonate2(_ sender: DonateButton) {
        appPurchases.makePurchase(item: .donate2)
    }

    @IBAction func onDonate3(_ sender: DonateButton) {
        appPurchases.makePurchase(item: .donate3)
    }

    @IBAction func onRating(_ sender: DonateButton) {
        if #available(iOS 10.3, *){
            SKStoreReviewController.requestReview()
        }
        else {
            rateApp(appId: "1394064506")
        }
    }
}


fileprivate func rateApp(appId: String) {
    openUrl("itms-apps://itunes.apple.com/app/" + appId)
}

fileprivate func openUrl(_ urlString: String) {
    let url = URL(string: urlString)!
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

