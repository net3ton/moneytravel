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
    
    private struct Position: Equatable {
        var x: Int
        var y: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
    }
    
    private var selectedCell: Position?

    public var onPressedHandler: ((String) -> Void)?
    
    override func draw(_ rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30.0),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            ]
        
        let xsize = rect.width / CGFloat(COUNTX)
        let ysize = rect.height / CGFloat(COUNTY)
        
        let cnx = UIGraphicsGetCurrentContext()
        //cnx?.beginPath()

        for ix in 0...(COUNTX-1) {
            for iy in 0...(COUNTY-1) {
                
                if (selectedCell != nil && ix == selectedCell!.x && iy == selectedCell!.y) {
                    cnx?.setFillColor(COLOR_KEYS_SELECT.cgColor)
                }
                else {
                    cnx?.setFillColor(COLOR_KEYS.cgColor)
                }
                
                let rect = CGRect(x: CGFloat(ix) * xsize, y: CGFloat(iy) * ysize, width: xsize - 2, height: ysize - 2)
                //cnx?.addRect(rect)
                cnx?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 3.0).cgPath)
                cnx?.fillPath()
                
                let str = NSAttributedString(string: CHARS[iy][ix], attributes: attributes)
                let rect2 = CGRect(x: CGFloat(ix) * xsize, y: CGFloat(iy) * ysize + ysize/4, width: xsize - 2, height: ysize - 2)
                str.draw(in: rect2)
                cnx?.fillPath()
            }
        }
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
            let enteredChar = CHARS[sel.y][sel.x]
            onPressedHandler?(enteredChar)
            //sendActions(for: .valueChanged)
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
