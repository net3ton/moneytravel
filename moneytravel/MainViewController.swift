//
//  MainViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 19/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    @IBOutlet weak var sumField: UITextField!
    @IBOutlet weak var categoriesView: UICollectionView!
    @IBOutlet weak var spendView: UITableView!

    var categoriesDelegate: CategoriesViewDelegate?
    var spendDelegate: SpendViewDelegate?
    let sumFieldDelegate = SumTextDelegate()

    private func initCategories() {
        initCategoryBase()
        
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
    }

    private func initSpend() {
        fetchSpends()
        spendDelegate = SpendViewDelegate()

        spendView.register(UINib.init(nibName: "SpendViewCell", bundle: nil), forCellReuseIdentifier: "SpendCell")
        spendView.delegate = spendDelegate
        spendView.dataSource = spendDelegate

        //spendView.tableFooterView?.isHidden = true

        for constr in spendView.constraints {
            if constr.identifier == "height" {
                constr.constant = CGFloat(getSpendsCount()) * SpendViewCell.HEIGHT
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appSettings.load()
        sumField.delegate = sumFieldDelegate

        initCategories()
        initSpend()
    }

    func initCategoryBase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: context)
        let fetchRequest = NSFetchRequest<CategoryModel>(entityName: "Category")

        let catList = [
            ("Food", "food"),
            ("House", "rent"),
            ("Cafe", "cafe"),
            ("Games", "games"),
            ("Gift", "gifts"),
            ("Museum", "museums"),
            ("Transport", "transport"),
            ("Restaurant", "restaurant"),
            ("Canteen", "canteen"),
            ("Clothes", "clothes"),
            ("Entertain", "entertain")
        ]

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                for (iconname, name) in catList {
                    let cat = NSManagedObject(entity: categoryEntity!, insertInto: context) as! CategoryModel
                    cat.name = name
                    cat.iconname = iconname
                }

                try context.save()
            }

            appCategories = try context.fetch(fetchRequest)
        }
        catch let error {
            print("Categories init ERROR: " + error.localizedDescription)
        }
    }

    func fetchSpends() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<SpendModel>(entityName: "Spend")

        do {
            appSpends = try context.fetch(fetchRequest)
        }
        catch let error {
            print("Spends init ERROR: " + error.localizedDescription)
        }
    }

    func addSpend(cat: CategoryModel, sum: Float, curIso: String, bsum: Float, bcurIso: String, comment: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let spendEntity = NSEntityDescription.entity(forEntityName: "Spend", in: context)

        let spend = NSManagedObject(entity: spendEntity!, insertInto: context) as! SpendModel
        spend.category = cat
        spend.comment = comment
        spend.date = Date()
        spend.sum = sum
        spend.currency = curIso
        spend.bsum = bsum
        spend.bcurrency = bcurIso

        do {
            try context.save()
            appSpends?.append(spend)
            spendView.reloadData()
        }
        catch let error {
           print("Failed to add spend. ERROR: " + error.localizedDescription)
        }
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}
    
    /*
     self.view.layoutIfNeeded()
     UIView.animateWithDuration(1, animations: {
     self.sampleConstraint.constant = 20
     self.view.layoutIfNeeded()
     })
    */
    
    private var sumString: String = ""
    
    @IBAction func onMoneyEnter(_ sender: MoneyKeyboard) {
        updateSum(add: sender.getEnteredChar())
        sumField.text = prepareSumString(instr: sumString)
    }

    private func updateSum(add: String) {
        if add == "del" {
            if sumString.count > 0 {
                sumString = String(sumString.prefix(sumString.count - 1))
            }
            return
        }

        if sumString.contains(".") {
            if add == "." {
                return
            }
            
            let point = sumString.index(of: ".")!
            if sumString.count - point.encodedOffset > 2 {
                return
            }
        }

        sumString += add
    }

    func prepareSumString(instr: String) -> String {
        if instr.isEmpty {
            return ""
        }

        let point = instr.index(of: ".") ?? instr.endIndex
        let lstr = instr[..<point]
        let rstr = instr[point...]

        let lval: Int = Int(lstr)!

        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "\u{00a0}" // non breaking space
        formatter.groupingSize = 3

        let newlstr = formatter.string(from: NSNumber(value: lval))
        return newlstr! + rstr
    }
}


class SumTextDelegate: NSObject, UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("clear")
        return true
    }
}
