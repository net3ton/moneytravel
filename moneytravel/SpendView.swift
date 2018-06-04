//
//  SpendViewCell.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 23/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class SpendViewCell: UITableViewCell {
    public static let ID = "SpendCell"
    public static let HEIGHT: CGFloat = 44.0
    public static let HEIGHT_HEADER: CGFloat = 36.0
    public static let HEIGHT_FOOTER: CGFloat = 4.0

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var sumBase: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 5.0
    }

    //override func setSelected(_ selected: Bool, animated: Bool) {
    //    super.setSelected(selected, animated: animated)
    //    // Configure the view for the selected state
    //}
}

class SpendViewHeader: UITableViewHeaderFooterView {
    public static let ID = "SpendHeader"
    public weak var content: SpendViewHeaderContent!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        content = UINib(nibName: "SpendViewHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SpendViewHeaderContent
        content.backgroundColor = COLOR4
        //content.layer.cornerRadius = 5.0

        addSubview(content)
        //layer.cornerRadius = 5.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        content.frame = self.bounds
        //layer.cornerRadius = 5.0
    }
}

class SpendViewHeaderContent: UIView {
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var sumBase: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var dateName: UILabel!
    @IBOutlet weak var dayProgress: UIProgressView!
}

/*
class SpendViewFooter: UITableViewHeaderFooterView {
    public static let ID = "SpendFooter"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let view = UIView()
        view.backgroundColor = UIColor.white
        addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
*/


class SpendViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    func getContentHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for spendsInfo in appSpends.daily {
            height += CGFloat(spendsInfo.spends.count) * SpendViewCell.HEIGHT
        }

        height += CGFloat(appSpends.daily.count) * SpendViewCell.HEIGHT_HEADER
        height += CGFloat(appSpends.daily.count) * SpendViewCell.HEIGHT_FOOTER
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

        let cell = tableView.dequeueReusableCell(withIdentifier: SpendViewCell.ID, for: indexPath) as! SpendViewCell
        cell.icon.image = spend.category?.icon
        cell.comment.text = spend.category?.name
        cell.sum.text = spend.getSumString()
        cell.sumBase.text = spend.getBaseSumString()
        cell.backgroundColor = (indexPath.row % 2 == 1) ? COLOR_SP1 : COLOR_SP3
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SpendViewCell.HEIGHT
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dayInfo = appSpends.daily[section]
        let budgetInfo = dayInfo.getBudgetInfo()
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpendViewHeader.ID) as! SpendViewHeader
        header.content.date.text = dayInfo.getDateString()
        header.content.dateName.text = dayInfo.getDateSubname()
        header.content.sum.text = budgetInfo.budgetLeft
        header.content.sumBase.text = budgetInfo.baseSum
        header.content.dayProgress.progress = budgetInfo.budgetProgress
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SpendViewCell.HEIGHT_HEADER
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SpendViewCell.HEIGHT_FOOTER
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(String(indexPath.row))
    }
}
