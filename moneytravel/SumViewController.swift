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
    private var initCurrency = "USD"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveSum))
        keyboardField.setInput(field: textField!)
        keyboardField.setValue(initSum)
        currencyLabel.text = initCurrency
    }
    
    public func setup(caption: String, sum: Float, currency: String) {
        navigationItem.title = caption
        initSum = sum
        initCurrency = currency
    }

    @objc func saveSum() {
        navigationController?.popViewController(animated: true)
        onSumEntered?(keyboardField.getValue())
    }
}
