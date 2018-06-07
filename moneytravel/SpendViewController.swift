//
//  SpendViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 04/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewController: UITableViewController {
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    public var spendInfo: SpendModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
        updateInfo()
    }
    
    private func updateInfo() {
        guard let info = spendInfo else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "mm:HH, dd LLLL"

        catLabel.text = info.category?.name
        dateLabel.text = formatter.string(from: info.date!)
        sumLabel.text = sum_to_string(sum: info.sum, currency: info.currency!)
        commentLabel.text = info.comment
    }
    
    @objc private func save() {
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let removeController = UIAlertController(title: nil, message: "Delete the record? It can't be undone", preferredStyle: .actionSheet);

            removeController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
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
            nameEdit.setup(caption: "Comment", text: "")
            nameEdit.onTextEntered = { text in
                //self.name = text
                //self.updateInfo()
            }
        }
        else if segue.identifier == "spend-date" {
            let dateEdit = segue.destination as! DateViewController
            dateEdit.setup(caption: "Date and Time", date: Date())
            dateEdit.onDatePicked = { date in
                //self.name = text
                //self.updateInfo()
            }
        }
    }
}
