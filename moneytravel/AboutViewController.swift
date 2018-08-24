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
            rateApp(appId: "ID")
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


@IBDesignable class DonateButton: UIButton {
    private var tapState: Bool = false
    private var priceLabel: UILabel?

    public var price: String? {
        set {
            priceLabel?.text = newValue
        }
        get {
            return priceLabel?.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        self.layer.cornerRadius = 5

        priceLabel = UILabel()
        addSubview(priceLabel!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imgView = self.imageView {
            imgView.frame = CGRect(x: 8, y: self.bounds.origin.y + 8, width: self.bounds.height - 16, height: self.bounds.height - 16)
        }
        
        if let txtLabel = self.titleLabel {
            txtLabel.frame = CGRect(x: 50, y: self.bounds.origin.y, width: self.bounds.width / 2, height: self.bounds.height)
            txtLabel.textAlignment = .left
        }

        if let priceLabel = self.priceLabel {
            priceLabel.frame = CGRect(x: self.bounds.width - 188, y: self.bounds.origin.y, width: 180, height: self.bounds.height)
            priceLabel.textAlignment = .right
        }
    }

    private func processTap(pressed: Bool) {
        let alpha: CGFloat = pressed ? 0.4 : 1.0
        tapState = pressed

        self.imageView?.alpha = alpha
        self.titleLabel?.alpha = alpha
        self.priceLabel?.alpha = alpha
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        processTap(pressed: true)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let inView = self.bounds.contains(touches.first!.location(in: self))
        if !inView {
            processTap(pressed: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        processTap(pressed: false)
    }
}
