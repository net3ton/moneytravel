//
//  MoneyViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 09/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SumViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var keyboardField: MoneyKeyboardWithInput!
    
    public var onSumEntered: ((Float) -> Void)?
    private var initSum: Float = 0.0
    private var initCurrency: String?
    private var initFraction: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".loc(), style: .plain, target: self, action: #selector(saveSum))
        keyboardField.setInput(field: textField!)
        keyboardField.setValue(initSum)
        keyboardField.fractionEnabled = initFraction
        currencyLabel.text = initCurrency
        currencyLabel.isHidden = (initCurrency == nil)
    }
    
    public func setup(caption: String, sum: Float, currency: String?, fraction: Bool = true) {
        navigationItem.title = caption
        initSum = sum
        initCurrency = currency
        initFraction = fraction
    }

    @objc func saveSum() {
        navigationController?.popViewController(animated: true)
        onSumEntered?(keyboardField.getValue())
    }
}
