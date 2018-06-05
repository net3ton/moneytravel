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
        formatter.dateFormat = "dd.MM.yyyy"

        catLabel.text = info.category?.name
        dateLabel.text = formatter.string(from: info.date!)
        sumLabel.text = sum_to_string(sum: info.sum, currency: info.currency!)
        commentLabel.text = info.comment
    }
    
    @objc private func save() {
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
