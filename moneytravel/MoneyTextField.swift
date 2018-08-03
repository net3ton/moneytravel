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

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }

    private func initLabel() {
        mulLabel.font = UIFont.systemFont(ofSize: 16)
        mulLabel.textColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:0.30)
        mulLabel.textAlignment = .right
        
        self.addSubview(mulLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mulLabel.frame = CGRect(x: self.bounds.width - 130, y: 0, width: 100, height: self.bounds.height)
    }

    public var multilier: String? {
        set {
            mulLabel.text = newValue
        }
        get {
            return mulLabel.text
        }
    }
}
