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
    @IBOutlet weak var categoriesView: UICollectionView!
    @IBOutlet weak var spendView: UITableView!
    
    var categoriesDelegate: CategoriesViewDelegate?
    var spendDelegate: SpendViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let COUNTX: CGFloat = 5
        let COUNTY: CGFloat = 2
        let SPACING: CGFloat = 2
        
        let cellsize = (categoriesView.frame.width - CGFloat(COUNTX-1) * SPACING) / COUNTX
        let viewheight = cellsize * COUNTY + (COUNTY-1) * SPACING

        categoriesDelegate = CategoriesViewDelegate(cellSize: cellsize)
        
        categoriesView.register(UINib.init(nibName: "CategoryViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        categoriesView.delegate = categoriesDelegate
        categoriesView.dataSource = categoriesDelegate
        
        for constr in categoriesView.constraints {
            if constr.identifier == "height" {
                constr.constant = viewheight
            }
        }
        
        //print(NSLocale.isoCurrencyCodes.count)
        //for iso in NSLocale.isoCurrencyCodes {
        //    print(iso)
        //}
        
        spendDelegate = SpendViewDelegate()
        
        spendView.register(UINib.init(nibName: "SpendViewCell", bundle: nil), forCellReuseIdentifier: "SpendCell")
        spendView.delegate = spendDelegate
        spendView.dataSource = spendDelegate
        
        for constr in spendView.constraints {
            if constr.identifier == "height" {
                constr.constant = CGFloat(spends.count) * CGFloat(SPEND_HEIGHT)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     self.view.layoutIfNeeded()
     UIView.animateWithDuration(1, animations: {
     self.sampleConstraint.constant = 20
     self.view.layoutIfNeeded()
     })
    */
    
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
}
