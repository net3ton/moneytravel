//
//  SpendViewCell.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewCell: UITableViewCell {
    public static let HEIGHT: CGFloat = 44.0

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var sumBase: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        //self.backgroundColor = COLOR_MAIN
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

class SpendViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSpendsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spend = appSpends![indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "SpendCell", for: indexPath) as! SpendViewCell
        cell.icon.image = spend.category?.icon
        cell.comment.text = spend.category?.name
        cell.sum.text = String(spend.sum) + " RUB"
        cell.sumBase.text = "12.23 USD"
        cell.backgroundColor = (indexPath.row % 2 == 1) ? COLOR_SP1 : COLOR_SP3
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ha ha ha header"
    }
    
    //func tableviewheader
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SpendViewCell.HEIGHT
    }
}
