//
//  IPadSupport.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/09/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func adjustToIpad() {
        if UIDevice.current.userInterfaceIdiom != .pad {
            return
        }
        
        let uiroot = UIView()
        uiroot.frame = self.view.frame
        uiroot.backgroundColor = UIColor(red:0.35, green:0.64, blue:0.88, alpha:1.0)
        
        let width = self.view.frame.width * 0.58
        let x = (self.view.frame.width - width) / 2
        self.view.frame = CGRect(x: x, y: 0, width: width, height: self.view.frame.height)
        
        uiroot.addSubview(self.view)
        self.view = uiroot
    }
    
    func getActionSheetType() -> UIAlertController.Style {
        return (UIDevice.current.userInterfaceIdiom == .pad) ? .alert : .actionSheet
    }
}


@IBDesignable class UIViewControllerMod: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustToIpad()
    }
}


@IBDesignable class UITableViewControllerMod: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustToIpad()
    }
    
    override var tableView: UITableView! {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return self.view.subviews[0] as? UITableView
            }
            
            return self.view as? UITableView
        }
        set {
        }
    }
}


@IBDesignable class UICollectionViewControllerMod: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustToIpad()
    }
    
    /*
    override var collectionView: UICollectionView! {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return self.view.subviews[0] as? UICollectionView
            }
            
            return self.view as? UICollectionView
        }
        set {
        }
    }
    */
}
