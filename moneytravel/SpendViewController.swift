//
//  SpendViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 04/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewController: UITableViewControllerMod {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    
    private var spendInfo: SpendModel?

    private var date: Date = Date()
    private var sum: Float = 0.0
    private var exchangeRate: Float = 1.0
    private var currency: String = "USD"
    private var comment: String?
    private var category: CategoryModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".loc(), style: .plain, target: self, action: #selector(save))
        navigationItem.title = "EXPENSE".loc()

        updateInfo()
    }

    public func setup(sinfo: SpendModel) {
        spendInfo = sinfo

        date = sinfo.date!
        sum = sinfo.sum
        exchangeRate = sinfo.sum / sinfo.bsum
        currency = sinfo.currency!
        comment = sinfo.comment
        category = sinfo.category
    }
    
    private func updateInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd LLLL"

        categoryLabel.text = category!.name
        categoryIcon.image = category!.icon
        dateLabel.text = formatter.string(from: date)
        currencyLabel.text = currency
        sumLabel.text = sum_to_string(sum: sum, currency: currency)
        exchangeRateLabel.text = sum_to_string(sum: exchangeRate, currency: currency)
        commentLabel.text = comment
    }
    
    @objc private func save() {
        navigationController?.popViewController(animated: true)

        spendInfo?.date = date
        spendInfo?.sum = sum
        spendInfo?.bsum = sum / exchangeRate
        spendInfo?.currency = currency
        spendInfo?.comment = comment
        spendInfo?.catid = category?.uid

        appSpends.update(spend: spendInfo!)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {

            let removeController = UIAlertController(title: nil, message: "DELETE_MSG".loc(), preferredStyle: getActionSheetType())
            removeController.addAction(UIAlertAction(title: "DELETE".loc(), style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                appSpends.delete(spend: self.spendInfo!)
            }))
            removeController.addAction(UIAlertAction(title: "CANCEL".loc(), style: .cancel))

            present(removeController, animated: true) {
                if let selected = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selected, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "spend-comment" {
            let nameEdit = segue.destination as! TextViewController
            nameEdit.setup(caption: "COMMENT".loc(), text: comment ?? "")
            nameEdit.onTextEntered = { text in
                self.comment = text.isEmpty ? nil : text
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-date" {
            let dateEdit = segue.destination as! DateViewController
            dateEdit.setup(caption: "DATE_TIME".loc(), date: date)
            dateEdit.onDatePicked = { date in
                self.date = date
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-sum" {
            let sumEdit = segue.destination as! SumViewController
            sumEdit.setup(caption: "SUM".loc(), sum: sum, currency: spendInfo?.currency ?? "")
            sumEdit.onSumEntered = { sum in
                if sum > 0 {
                    self.sum = sum
                    self.updateInfo()
                }
            }
        }
        else if segue.identifier == "spend-exchange" {
            let sumEdit = segue.destination as! SumViewController
            let exchangeRate = (spendInfo?.sum ?? 0.0) / (spendInfo?.bsum ?? 1.0)
            sumEdit.setup(caption: "EXCHANGE_RATE".loc(), sum: exchangeRate, currency: spendInfo?.currency ?? "")
            sumEdit.onSumEntered = { rate in
                if rate > 0 {
                    self.exchangeRate = rate
                    self.updateInfo()
                }
            }
        }
        else if segue.identifier == "spend-category" {
            let catSelect = segue.destination as! CategoriesSelectViewController
            catSelect.onCateggorySelected = { category in
                self.category = category
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-currency" {
            let currencyPicker = segue.destination as! CurrenciesViewController
            currencyPicker.selectedHandler = { iso in
                self.currency = iso
                self.updateInfo()
            }
        }
    }
}
