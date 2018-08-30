//
//  DonateButton.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 27/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

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
            txtLabel.frame = CGRect(x: 50, y: self.bounds.origin.y, width: self.bounds.width - 100, height: self.bounds.height)
            txtLabel.textAlignment = .left
        }
        
        if let priceLabel = self.priceLabel {
            priceLabel.frame = CGRect(x: self.bounds.width - 188, y: self.bounds.origin.y, width: 180, height: self.bounds.height)
            priceLabel.textAlignment = .right
        }
    }
    
    private func applyPressAlpha(_ alpha: CGFloat) {
        imageView?.alpha = alpha
        titleLabel?.alpha = alpha
        priceLabel?.alpha = alpha
    }
    
    private func processTap(pressed: Bool) {
        tapState = pressed
        
        if pressed  {
            applyPressAlpha(0.4)
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.applyPressAlpha(1.0)
            }
        }
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
