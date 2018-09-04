//
//  MoneyTextField.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 02/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class MoneyTextField: UITextField {
    var mulLabel: UILabel = UILabel()
    var currencyLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }

    private func initLabel() {
        mulLabel.font = UIFont.systemFont(ofSize: 14)
        mulLabel.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.30)
        mulLabel.textAlignment = .right
        self.addSubview(mulLabel)

        currencyLabel.font = UIFont.systemFont(ofSize: 14)
        currencyLabel.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.30)
        currencyLabel.textAlignment = .right
        self.addSubview(currencyLabel)
        
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc func textChanged() {
        layoutLabels()
    }
    
    private func layoutLabels() {
        let currentText = text != nil ? text! : ""
        let offset = self.bounds.width - (currentText.isEmpty ? 106 : 130)

        mulLabel.frame = CGRect(x: offset, y: 4, width: 100, height: 14)
        currencyLabel.frame = CGRect(x: offset, y: self.bounds.height - 18, width: 100, height: 14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }

    public var multilier: String? {
        set {
            mulLabel.text = newValue
        }
        get {
            return mulLabel.text
        }
    }

    public var currency: String? {
        set {
            currencyLabel.text = newValue
        }
        get {
            return currencyLabel.text
        }
    }
}
