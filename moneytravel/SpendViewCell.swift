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
    public static let HEIGHT_HEADER: CGFloat = 30.0

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
    
    func getContentHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for spendsInfo in appSpends.daily {
            height += CGFloat(spendsInfo.spends.count) * SpendViewCell.HEIGHT
        }

        height += CGFloat(appSpends.daily.count) * SpendViewCell.HEIGHT_HEADER
        return height
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return appSpends.daily.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appSpends.daily[section].spends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spend = appSpends.daily[indexPath.section].spends[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "SpendCell", for: indexPath) as! SpendViewCell
        cell.icon.image = spend.category?.icon
        cell.comment.text = spend.category?.name
        cell.sum.text = spend.getSumString()
        cell.sumBase.text = spend.getBaseSumString()
        cell.backgroundColor = (indexPath.row % 2 == 1) ? COLOR_SP1 : COLOR_SP3
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return appSpends.daily[section].getInfoString()
    }

    //func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //    
    //}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SpendViewCell.HEIGHT
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SpendViewCell.HEIGHT_HEADER
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
