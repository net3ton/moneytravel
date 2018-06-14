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
    @IBOutlet weak var showMore: UIButton!
    
    var categoriesDelegate: CategoriesViewDelegate?
    var spendDelegate: SpendViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appSettings.load()
        
        initCategories()
        initSpends()
        
        showMore.layer.cornerRadius = 3.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selected = spendView.indexPathForSelectedRow {
            spendView.deselectRow(at: selected, animated: true)
        }

        updateSpendsView()
        categoriesView.reloadData()
    }

    private func initCategories() {
        let viewInfo = CategoryViewCell.getCellSizeAndHeight(width: categoriesView.frame.width)

        categoriesDelegate = CategoriesViewDelegate(cellSize: viewInfo.csize)
        categoriesDelegate?.onCategoryPressed = onCategoryPressed

        categoriesView.register(CategoryViewCell.getNib(), forCellWithReuseIdentifier: CategoryViewCell.ID)
        categoriesView.delegate = categoriesDelegate
        categoriesView.dataSource = categoriesDelegate

        for constr in categoriesView.constraints {
            if constr.identifier == "height" {
                constr.constant = viewInfo.height + 1.0
            }
        }
    }

    private func initSpends() {
        spendDelegate = SpendViewDelegate()
        spendDelegate?.onSpendPressed = showSpendInfo

        spendView.register(SpendViewCell.getNib(), forCellReuseIdentifier: SpendViewCell.ID)
        spendView.register(SpendViewHeader.self, forHeaderFooterViewReuseIdentifier: SpendViewHeader.ID)
        spendView.register(SpendViewFooter.self, forHeaderFooterViewReuseIdentifier: SpendViewFooter.ID)
        spendView.delegate = spendDelegate
        spendView.dataSource = spendDelegate
        //updateSpendsView()
    }

    private func showSpendInfo(spend: SpendModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "spend-info") as! SpendViewController

        view.setup(sinfo: spend)
        navigationController?.pushViewController(view, animated: true)
    }
    
    private func updateSpendsView() {
        for constr in spendView.constraints {
            if constr.identifier == "height" {
                constr.constant = spendDelegate!.getContentHeight()
            }
        }

        spendView.reloadData()
        updateHeader()
    }

    private func onCategoryPressed(cat: CategoryModel) {
        if keysView.getValue() <= 0 {
            return
        }

        let sum = keysView.getValue()
        let bsum = sum / appSettings.exchangeRate

        appSpends.add(category: cat, sum: sum, curIso: appSettings.currency, bsum: bsum, bcurIso: appSettings.currencyBase, comment: "")
        updateSpendsView()
        keysView.clear()
    }

    private func updateHeader() {
        let sum = appStats.getSumSince(date: appSettings.headerSince)
        let sumString = sum_to_string(sum: sum, currency: appSettings.currencyBase)

        navigationItem.title = sumString
    }

    @IBAction func onShowHistory(_ sender: UIButton) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "history") as! HistoryViewController
        
        navigationController?.pushViewController(view, animated: true)
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
