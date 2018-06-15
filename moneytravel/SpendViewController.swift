//
//  SpendViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 04/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewController: UITableViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!

    private var spendInfo: SpendModel?

    private var date: Date = Date()
    private var sum: Float = 0.0
    private var exchangeRate: Float = 1.0
    private var currency: String = "USD"
    private var comment: String = ""
    private var category: CategoryModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        //navigationItem.backBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: nil, action: nil)
        //navigationController?.navigationBar.backItem?.title = "Back"
        //navigationItem.title = "Spend record"

        updateInfo()
    }

    public func setup(sinfo: SpendModel) {
        spendInfo = sinfo

        date = sinfo.date!
        sum = sinfo.sum
        exchangeRate = sinfo.sum / sinfo.bsum
        currency = sinfo.currency!
        comment = sinfo.comment!
        category = sinfo.category
    }
    
    private func updateInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd LLLL"

        categoryLabel.text = category!.name
        categoryIcon.image = category!.icon
        dateLabel.text = formatter.string(from: date)
        sumLabel.text = sum_to_string(sum: sum, currency: currency)
        exchangeRateLabel.text = sum_to_string(sum: exchangeRate, currency: currency)
        commentLabel.text = comment
    }
    
    @objc private func save() {
        navigationController?.popViewController(animated: true)

        spendInfo?.date = date
        spendInfo?.sum = sum
        spendInfo?.bsum = sum / exchangeRate
        spendInfo?.comment = comment
        spendInfo?.category = category

        appSpends.update(spend: spendInfo!)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let removeController = UIAlertController(title: nil, message: "Delete the record? It can't be undone", preferredStyle: .actionSheet);

            removeController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                appSpends.delete(spend: self.spendInfo!)
            }))
            removeController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

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
            nameEdit.setup(caption: "Comment", text: comment)
            nameEdit.onTextEntered = { text in
                self.comment = text
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-date" {
            let dateEdit = segue.destination as! DateViewController
            dateEdit.setup(caption: "Date and Time", date: date)
            dateEdit.onDatePicked = { date in
                self.date = date
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-sum" {
            let sumEdit = segue.destination as! SumViewController
            sumEdit.setup(caption: "Sum", sum: sum, currency: spendInfo?.currency ?? "")
            sumEdit.onSumEntered = { sum in
                self.sum = sum
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-exchange" {
            let sumEdit = segue.destination as! SumViewController
            let exchangeRate = (spendInfo?.sum ?? 0.0) / (spendInfo?.bsum ?? 1.0)
            sumEdit.setup(caption: "Exchange rate", sum: exchangeRate, currency: spendInfo?.currency ?? "")
            sumEdit.onSumEntered = { rate in
                self.exchangeRate = rate
                self.updateInfo()
            }
        }
        else if segue.identifier == "spend-category" {
            let catSelect = segue.destination as! CategoriesSelectViewController
            catSelect.onCateggorySelected = { category in
                self.category = category
                self.updateInfo()
            }
        }
    }
}
