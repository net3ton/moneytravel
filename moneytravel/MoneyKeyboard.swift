//
//  MoneyKeyboard.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

@IBDesignable class MoneyKeyboard: UIControl {
    let COUNTX = 3
    let COUNTY = 4
    let CHARS = [ ["1", "2", "3"],
                  ["4", "5", "6"],
                  ["7", "8", "9"],
                  [".", "0", "del"]]

    let ICONS = [ [nil, nil, nil],
                  [nil, nil, nil],
                  [nil, nil, nil],
                  [nil, nil, UIImage(named: "Backspace")]]

    private struct Position: Equatable {
        var x: Int
        var y: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }

    private var selectedCell: Position?
    public var onPressedHandler: ((String) -> Void)?
    public var fractionEnabled: Bool = true
    
    override func draw(_ rect: CGRect) {
        let fontSize: CGFloat = 30.0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            ]
        
        let xsize = rect.width / CGFloat(COUNTX)
        let ysize = rect.height / CGFloat(COUNTY)
        
        let cnx = UIGraphicsGetCurrentContext()
        //cnx?.beginPath()

        for ix in 0...(COUNTX-1) {
            for iy in 0...(COUNTY-1) {

                let rect = CGRect(x: CGFloat(ix) * xsize, y: CGFloat(iy) * ysize, width: xsize - 2, height: ysize - 2)
                let color = getKeyColor(pos: Position(x: ix, y: iy))

                cnx?.setFillColor(color)
                cnx?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 3.0).cgPath)
                cnx?.fillPath()

                if let icon = ICONS[iy][ix] {
                    let isize = min(rect.width, rect.height) * 0.75
                    let rectIcon = CGRect(x: rect.origin.x + (rect.width - isize)/2, y: rect.origin.y + (rect.height - isize)/2, width: isize, height: isize)

                    cnx?.setFillColor(UIColor.white.cgColor)
                    icon.withRenderingMode(.alwaysTemplate).draw(in: rectIcon)
                }
                else {
                    let rectStr = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.height - fontSize)/2, width: rect.width, height: fontSize)
                    
                    let str = NSAttributedString(string: CHARS[iy][ix], attributes: attributes)
                    str.draw(in: rectStr)
                }
                cnx?.fillPath()
            }
        }
    }

    private func getKeyColor(pos: Position) -> CGColor {
        if !isKeyEnabled(pos: pos) {
            return COLOR_KEYS_DISABLED.cgColor
        }

        if let sel = selectedCell {
            if pos == sel {
                return COLOR_KEYS_SELECT.cgColor
            }
        }

        return COLOR_KEYS.cgColor
    }
    
    private func isKeyEnabled(pos: Position) -> Bool {
        if !fractionEnabled && CHARS[pos.y][pos.x] == "." {
            return false
        }

        return true
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)

        updateSelection(point: touch.location(in: self))
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        if touch != nil {
            updateSelection(point: touch!.location(in: self))
        }

        if let sel = selectedCell {
            if isKeyEnabled(pos: sel) {
                let enteredChar = CHARS[sel.y][sel.x]
                onPressedHandler?(enteredChar)
            }
        }

        selectedCell = nil
        setNeedsDisplay()
    }

    private func updateSelection(point: CGPoint) {
        let sel = getCellPosition(pos: point)
        if (sel != selectedCell) {
            setNeedsDisplay()
        }

        selectedCell = sel
    }

    private func getCellPosition(pos: CGPoint) -> Position? {
        let xpos = Int(pos.x * CGFloat(COUNTX) / self.frame.width)
        let ypos = Int(pos.y * CGFloat(COUNTY) / self.frame.height)
        
        if (xpos < 0 || xpos >= COUNTX || ypos < 0 || ypos >= COUNTY) {
            return nil
        }

        return Position(x: xpos, y: ypos)
    }
}
