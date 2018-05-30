//
//  MoneyInput.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 27/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

@IBDesignable class MoneyInput: UIControl, UITextFieldDelegate {
    private var textField: UITextField?
    private var keysView: MoneyKeyboard?
    private var sumString: String = ""

    let TEXTF_HEIGHT: CGFloat = 40.0
    let SPACING: CGFloat = 8.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField = UITextField(frame: getTextFieldRect(rect: frame))
        textField?.borderStyle = .roundedRect
        textField?.placeholder = "EnterSum"
        textField?.backgroundColor = COLOR4
        textField?.font = UIFont.systemFont(ofSize: 30.0)
        textField?.textAlignment = .center
        textField?.delegate = self
        addSubview(textField!)
        
        keysView = MoneyKeyboard(frame: getKeysViewRect(rect: frame))
        keysView?.backgroundColor = UIColor.white
        keysView?.onPressedHandler = onMoneyEnter
        addSubview(keysView!)
    }

    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */

    override func layoutSubviews() {
        super.layoutSubviews();

        textField?.frame = getTextFieldRect(rect: self.bounds)
        keysView?.frame = getKeysViewRect(rect: self.bounds)
    }
    
    private func getTextFieldRect(rect: CGRect) -> CGRect {
        return CGRect(origin: rect.origin, size: CGSize(width: rect.width, height: TEXTF_HEIGHT))
    }
    
    private func getKeysViewRect(rect: CGRect) -> CGRect {
        let topoffset = TEXTF_HEIGHT + SPACING
        return CGRect(x: rect.origin.x, y: rect.origin.y + topoffset, width: rect.width, height: rect.height - topoffset)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        sumString = ""
        return true
    }
    
    // MARK: - Logic

    public func getValue() -> Float {
        guard let res = Float(sumString) else {
            return 0.0
        }

        return res
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
