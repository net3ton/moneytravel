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
    @IBOutlet weak var sumView: MoneyTextField!
    @IBOutlet weak var keysView: MoneyKeyboardWithInput!
    @IBOutlet weak var categoriesView: UICollectionView!
    @IBOutlet weak var spendView: UITableView!
    @IBOutlet weak var showMore: UIButton!

    var titlebar = Titlebar()
    var categoriesDelegate: CategoriesViewDelegate?
    var spendDelegate: SpendViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        appSettings.load()
        showMore.layer.cornerRadius = 3.0
        navigationItem.titleView = titlebar

        initKeyboard()
        initCategories()
        initSpends()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selected = spendView.indexPathForSelectedRow {
            spendView.deselectRow(at: selected, animated: true)
        }

        sumView.multilier = appSettings.inputMulStr
        //sumView.placeholder = "Enter sum in " + appSettings.currency

        updateSpendsView()
        categoriesView.reloadData()
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    private func initKeyboard() {
        keysView.setInput(field: sumView)
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
        spendDelegate?.onTMarkPressed = showTMarkInfo
        spendDelegate?.initClasses(for: spendView)

        spendView.delegate = spendDelegate
        spendView.dataSource = spendDelegate
    }

    private func showSpendInfo(spend: SpendModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "spend-info") as! SpendViewController

        view.setup(sinfo: spend)
        navigationController?.pushViewController(view, animated: true)
    }

    private func showTMarkInfo(tmark: MarkModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "tmark-info") as! TStampViewController
        
        view.setup(mark: tmark)
        navigationController?.pushViewController(view, animated: true)
    }

    private func updateSpendsView() {
        lastSpends.checkDays()
        spendDelegate?.data = lastSpends.daily

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

        let sum = keysView.getValue() * Float(appSettings.inputMul)
        let bsum = sum / appSettings.exchangeRate

        appSpends.add(category: cat, sum: sum, curIso: appSettings.currency, bsum: bsum, bcurIso: appSettings.currencyBase, comment: "")
        updateSpendsView()
        keysView.clear()
    }

    private func updateHeader() {
        let stats = appStats.getSumSince(date: appSettings.headerSince)

        titlebar.sum = stats.sum
        titlebar.days = stats.days
    }

    @IBAction func onPlacePressed(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: "New Timestamp", message: "", preferredStyle: .alert)
        popup.addTextField { (textField) in
            textField.text = ""
        }

        popup.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            let name = popup.textFields?.first?.text ?? ""
            if !name.isEmpty {
                appTimestamps.add(name: name)
                self.updateSpendsView()
            }
        })

        popup.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(popup, animated: true)
    }
}
