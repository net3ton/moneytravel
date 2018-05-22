//
//  MainViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var sumField: UITextField!

    @IBAction func onMoneyEnter(_ sender: MoneyKeyboard) {
        var current: String = (sumField.text ?? "")
        let add: String = (sender.enteredChar ?? "")
        
        if (add == "." && current.contains(".")) {
            return
        }
        
        if (add == "del") {
            if (current.count > 0) {
                current = String(current.prefix(current.count - 1))
            }
        }
        else {
            current += add
        }
        
        sumField.text = current
    }
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
}
