//
//  TextViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 06/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    public var onTextEntered: ((String) -> Void)?
    private var initText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".loc(), style: .plain, target: self, action: #selector(saveText))
        textField.becomeFirstResponder()
        textField.text = initText
    }

    public func setup(caption: String, text: String) {
        navigationItem.title = caption
        initText = text
    }

    @objc func saveText() {
        navigationController?.popViewController(animated: true)
        onTextEntered?(textField.text ?? "")
    }
}
