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

    public var onSumEntered: ((Float) -> Void)?
    private var initSum: Float = 0.0
    private var initCurrency = "USD"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveSum))
        textField.keyboardType = .decimalPad
        textField.becomeFirstResponder()
        
        textField.text = String.init(format: "%.02f", initSum)
        currencyLabel.text = initCurrency
    }

    public func setup(caption: String, sum: Float, currency: String) {
        navigationItem.title = caption
        initSum = sum
        initCurrency = currency
    }

    @objc func saveSum() {
        navigationController?.popViewController(animated: true)

        let fstr = textField.text ?? ""
        onSumEntered?(Float(fstr) ?? 0.0)
    }
}
