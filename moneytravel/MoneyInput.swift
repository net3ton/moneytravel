//
//  MoneyInput.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 27/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

@IBDesignable class MoneyKeyboardWithInput: MoneyKeyboard, UITextFieldDelegate {
    private var textField: UITextField?
    private var sumString: String = ""

    public func setInput(field: UITextField) {
        textField = field
        textField?.delegate = self
        onPressedHandler = onMoneyEnter
    }

    public func setValue(_ value: Float) {
        if value <= 0 {
            clear()
            return
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        sumString = formatter.string(from: value as NSNumber) ?? ""
        textField?.text = prepareSumString(instr: sumString)
    }
    
    // MARK: - UITextFieldDelegate
    
    internal func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clear()
        return true
    }

    // MARK: - Logic
    
    public func getValue() -> Float {
        guard let res = Float(sumString) else {
            return 0.0
        }
        
        return res
    }

    public func clear() {
        textField?.text = ""
        sumString = ""
    }

    private func onMoneyEnter(add: String) {
        sumString = updateSum(instr: sumString, add: add)
        textField?.text = prepareSumString(instr: sumString)
    }
    
    private func updateSum(instr: String, add: String) -> String {
        if add == "del" {
            if instr.count > 0 {
                return String(instr.prefix(instr.count - 1))
            }
            return instr
        }
        
        if instr.contains(".") {
            if add == "." {
                return instr
            }
            
            let point = instr.index(of: ".")!
            if instr.count - point.encodedOffset > 2 {
                return instr
            }
        }
        
        return instr + add
    }
    
    private func prepareSumString(instr: String) -> String {
        if instr.isEmpty {
            return ""
        }
        
        let point = instr.index(of: ".") ?? instr.endIndex
        let lstr = instr[..<point]
        let rstr = instr[point...]
        
        guard let lval: Int = Int(lstr) else {
            return instr
        }
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "\u{00a0}" // non-breaking space
        formatter.groupingSize = 3
        
        let newlstr = formatter.string(from: NSNumber(value: lval))
        return newlstr! + rstr
    }
}
