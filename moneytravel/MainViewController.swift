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
    @IBOutlet weak var keysView: MoneyInput!
    @IBOutlet weak var categoriesView: UICollectionView!
    @IBOutlet weak var spendView: UITableView!

    var categoriesDelegate: CategoriesViewDelegate?
    var spendDelegate: SpendViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appSettings.load()
        
        initCategories()
        initSpends()
    }
    
    private func initCategories() {
        initCategoryBase()
        
        let COUNTX: CGFloat = 5
        let COUNTY: CGFloat = 2
        let SPACING: CGFloat = 2
        
        let cellsize = (categoriesView.frame.width - CGFloat(COUNTX-1) * SPACING) / COUNTX
        let viewheight = cellsize * COUNTY + (COUNTY-1) * SPACING
        
        categoriesDelegate = CategoriesViewDelegate(cellSize: cellsize)
        categoriesDelegate?.onCategoryPressed = onCategoryPressed
        
        categoriesView.register(UINib.init(nibName: "CategoryViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        categoriesView.delegate = categoriesDelegate
        categoriesView.dataSource = categoriesDelegate
        
        for constr in categoriesView.constraints {
            if constr.identifier == "height" {
                constr.constant = viewheight
            }
        }
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
    
    private func initSpends() {
        spendDelegate = SpendViewDelegate()

        spendView.register(UINib.init(nibName: "SpendViewCell", bundle: nil), forCellReuseIdentifier: SpendViewCell.ID)
        spendView.register(SpendViewHeader.self, forHeaderFooterViewReuseIdentifier: SpendViewHeader.ID)
        spendView.register(SpendViewFooter.self, forHeaderFooterViewReuseIdentifier: SpendViewFooter.ID)
        spendView.delegate = spendDelegate
        spendView.dataSource = spendDelegate
        updateSpendsView()
    }

    private func updateSpendsView() {
        for constr in spendView.constraints {
            if constr.identifier == "height" {
                constr.constant = spendDelegate!.getContentHeight()
            }
        }

        spendView.reloadData()
    }

    private func onCategoryPressed(cat: CategoryModel) {
        if keysView.getValue() <= 0 {
            return
        }

        let sum = keysView.getValue()
        let bsum = sum / appSettings.exchangeRate

        appSpends.addSpend(cat: cat, sum: sum, curIso: appSettings.currency, bsum: bsum, bcurIso: appSettings.currencyBase, comment: "")
        updateSpendsView()
        keysView.clear()
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
}
