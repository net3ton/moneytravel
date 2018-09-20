//
//  MoneyKeyboard.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

@IBDesignable class MoneyKey: UIControl {
    private var keyLabel: UILabel?
    private var keyIcon: UIImageView?
    
    private var keyChar: String = ""
    private var tapState: Bool = false
    
    public var onKeyPressed: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(key: String, icon: UIImage?) {
        super.init(frame: CGRect())
        
        keyChar = key
        layer.cornerRadius = 3
        backgroundColor = COLOR_KEYS
        
        if icon != nil {
            keyIcon = UIImageView()
            keyIcon?.image = icon?.withRenderingMode(.alwaysTemplate)
            keyIcon?.contentMode = .center
            keyIcon?.tintColor = UIColor.white
            addSubview(keyIcon!)
        }
        else {
            keyLabel = UILabel()
            keyLabel?.text = key
            keyLabel?.font = UIFont.systemFont(ofSize: 30)
            keyLabel?.textColor = UIColor.white
            keyLabel?.textAlignment = .center
            addSubview(keyLabel!)
        }
    }

    override func layoutSubviews() {
        if let klabel = keyLabel {
            klabel.frame = bounds
        }
        if let kicon = keyIcon {
            kicon.frame = bounds
        }
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? COLOR_KEYS : COLOR_KEYS_DISABLED
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        processSelection(true)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        if bounds.contains(touch.location(in: self)) {
            processSelection(true)
        }
        else {
            processSelection(false)
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        if tapState {
            onKeyPressed?(keyChar)
        }
        
        processSelection(false)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        processSelection(false)
    }
    
    private func processSelection(_ pressed: Bool) {
        if tapState == pressed {
            return
        }
            
        if pressed {
            backgroundColor = COLOR_KEYS_SELECT
        }
        else {
            UIView.beginAnimations("key", context: nil)
            UIView.setAnimationDuration(0.5)
            backgroundColor = COLOR_KEYS
            UIView.commitAnimations()
        }

        tapState = pressed
    }
}


@IBDesignable class MoneyKeyboard: UIControl {
    private let COUNTX = 3
    private let CHARS = [ "1", "2", "3",
                          "4", "5", "6",
                          "7", "8", "9",
                          ".", "0", "del"]

    private var keys: [MoneyKey] = []
    
    public var onPressedHandler: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initControl()
    }
    
    private func initControl() {
        for char in CHARS {
            let icon = (char == "del") ? UIImage(named: "Backspace") : nil
            let key = MoneyKey(key: char, icon: icon)
            key.onKeyPressed = onKeyPressed
            keys.append(key)
            addSubview(key)
        }
    }
    
    override func layoutSubviews() {
        let COUNTY = keys.count / COUNTX
        let BORDER = 2
        
        let width = (Int(frame.width) - (COUNTX-1) * BORDER) / COUNTX
        let height = (Int(frame.height) - (COUNTY-1) * BORDER) / COUNTY
        
        for key in keys.enumerated() {
            let ix = key.offset % COUNTX
            let iy = key.offset / COUNTX

            key.element.frame = CGRect(x: ix * (width + BORDER), y: iy * (height + BORDER), width: width, height: height)
        }
    }
    
    private func onKeyPressed(char: String) {
        onPressedHandler?(char)
    }
    
    public func enableKey(key: String, enabled: Bool) {
        if let index = CHARS.index(of: key) {
            keys[index].isEnabled = enabled
        }
    }
}
