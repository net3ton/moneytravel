//
//  SpendViewCell.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var sum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class SpendViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spend = spends[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpendCell", for: indexPath) as! SpendViewCell
        cell.icon.image = getIcon(forCategory: spend.catId)
        cell.comment.text = getName(forCategory: spend.catId)
        cell.sum.text = String(spend.sum)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(SPEND_HEIGHT)
    }
}
