//
//  Funcs.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

func getUID() -> String {
    let timestamp =  Int((Date().timeIntervalSince1970 * 1000000.0).rounded())
    
    let p1: UInt32 = UInt32(timestamp & 0xFFFFFFFF)
    let p2: UInt32 = UInt32(timestamp >> 32) | UInt32(arc4random() << 16)
    
    return String(format:"'%08X%08X'", p2, p1)
}

func num_to_string(sum: Float) -> String {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "\u{00a0}" // non-breaking space
    formatter.groupingSize = 3
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    formatter.minimumIntegerDigits = 1
    
    return formatter.string(from: NSNumber(value: sum)) ?? "0.00"
}

func sum_to_string(sum: Float, currency: String) -> String {
    return String.init(format: "%@ %@", num_to_string(sum: sum), currency)
}

func get_delegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

func get_context() -> NSManagedObjectContext {
    return get_delegate().persistentContainer.viewContext
}

func top_view_controller(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return top_view_controller(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return top_view_controller(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return top_view_controller(controller: presented)
    }
    return controller
}

func int32_to_uicolor(_ val: Int32) -> UIColor {
    let r: CGFloat = CGFloat(val & 0xFF) / 255.0
    let g: CGFloat = CGFloat(val >> 8 & 0xFF) / 255.0
    let b: CGFloat = CGFloat(val >> 16 & 0xFF) / 255.0
    let a: CGFloat = CGFloat(val >> 24 & 0xFF) / 255.0
    
    return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
}

func uicolor_to_int32(_ val: UIColor) -> Int32 {
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    var a: CGFloat = 0
    val.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let ir = Int32(r * 255)
    let ig = Int32(g * 255) << 8
    let ib = Int32(b * 255) << 16
    let ia = Int32(a * 255) << 24
    return ia + ib + ig + ir
}
