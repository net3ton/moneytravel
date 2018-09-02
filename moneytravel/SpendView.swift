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

    public static func getNib() -> UINib {
        return UINib.init(nibName: "SpendViewCell", bundle: nil)
    }

    public func swapColor() {
        backgroundColor = (backgroundColor == COLOR_SPEND1) ? COLOR_SPEND2 : COLOR_SPEND1
    }
    
    public func refresh(_ info: SpendModel, index: Int) {
        let comm = info.comment ?? ""
        let category = info.category
        
        icon.image = category?.icon
        sum.text = info.getSumString()
        sumBase.text = info.getBaseSumString()
        comment.text = comm.isEmpty ? category?.name : comm
        backgroundColor = (index % 2 == 1) ? COLOR_SPEND1 : COLOR_SPEND2
    
        resizeComment()
    }

    private func resizeComment() {
        let COMMENT_INDENT: CGFloat = 20.0
        sum.sizeToFit()
        
        let width = frame.width - sum.frame.width - comment.frame.origin.x - COMMENT_INDENT
        comment.frame = CGRect(origin: comment.frame.origin, size: CGSize(width: width, height: comment.frame.height))
    }
}

class StampViewCell: UITableViewCell {
    public static let ID = "StampCell"
    public static let HEIGHT: CGFloat = 36.0

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var backLine1: UIView!
    @IBOutlet weak var backLine2: UIView!
    
    public var color: UIColor {
        set {
            backView.backgroundColor = newValue
            backView.layer.cornerRadius = 3
            backLine1.backgroundColor = newValue
            backLine2.backgroundColor = newValue
        }
        get {
            return UIColor.white
        }
    }

    public static func getNib() -> UINib {
        return UINib.init(nibName: "StampViewCell", bundle: nil)
    }

    public func refresh(_ info: MarkModel) {
        name.text = info.name
        color = info.color
    }
}

class SpendViewHeader: UITableViewHeaderFooterView {
    public static let ID = "SpendHeader"
    public weak var content: SpendViewHeaderContent!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        content = UINib(nibName: "SpendViewHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SpendViewHeaderContent
        content.backgroundColor = COLOR_SPEND_HEADER
        content.layer.cornerRadius = 3
        contentView.backgroundColor = UIColor.white

        addSubview(content)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        content.frame = self.bounds
    }

    public func refresh(_ info: DaySpends) {
        let budgetInfo = info.getBudgetInfo()
        
        content.date.text = info.getDateString()
        content.dateName.text = info.getDateSubname()
        content.sum.text = appSettings.budgetTotal ? budgetInfo.budgetTotal : budgetInfo.budgetLeft
        content.sum.textColor = budgetInfo.budgetPlus ? UIColor.black : UIColor.red
        content.sumBase.text = budgetInfo.baseSum
        content.dayProgress.progress = budgetInfo.budgetProgress
    }
}

class SpendViewHeaderContent: UIView {
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var sumBase: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var dateName: UILabel!
    @IBOutlet weak var dayProgress: UIProgressView!
}

class SpendViewFooter: UITableViewHeaderFooterView {
    public static let ID = "SpendFooter"
}


class SpendViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    public var onSpendPressed: ((SpendModel) -> Void)?
    public var onTMarkPressed: ((MarkModel) -> Void)?
    public var onHeaderPressed: (() -> Void)?
    public var data: [DaySpends] = []

    func initClasses(for tableView: UITableView) {
        tableView.register(SpendViewCell.getNib(), forCellReuseIdentifier: SpendViewCell.ID)
        tableView.register(StampViewCell.getNib(), forCellReuseIdentifier: StampViewCell.ID)
        tableView.register(SpendViewHeader.self, forHeaderFooterViewReuseIdentifier: SpendViewHeader.ID)
        tableView.register(SpendViewFooter.self, forHeaderFooterViewReuseIdentifier: SpendViewFooter.ID)
    }

    func getContentHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for spendsInfo in data {
            height += CGFloat(spendsInfo.spends.count) * SpendViewCell.HEIGHT
            height += CGFloat(spendsInfo.tmarks.count) * StampViewCell.HEIGHT
        }

        height += CGFloat(data.count) * SpendViewCell.HEIGHT_HEADER
        height += CGFloat(data.count) * SpendViewCell.HEIGHT_FOOTER
        return height
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.section].items[indexPath.row]

        if let spend = item.spend {
            let cell = tableView.dequeueReusableCell(withIdentifier: SpendViewCell.ID, for: indexPath) as! SpendViewCell
            cell.refresh(spend, index: indexPath.row)
            return cell
        }
        else if let tmark = item.tmark {
            let cell = tableView.dequeueReusableCell(withIdentifier: StampViewCell.ID, for: indexPath) as! StampViewCell
            cell.refresh(tmark)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = data[indexPath.section].items[indexPath.row]
        if item.spend != nil {
            return SpendViewCell.HEIGHT
        }

        return StampViewCell.HEIGHT
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpendViewHeader.ID) as! SpendViewHeader
        header.refresh(data[section])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onHeaderTap))
        header.addGestureRecognizer(tapRecognizer)
        return header
    }
    
    @objc func onHeaderTap() {
        appSettings.budgetTotal = !appSettings.budgetTotal
        onHeaderPressed?()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SpendViewCell.HEIGHT_HEADER
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SpendViewFooter.ID)
        view?.contentView.backgroundColor = COLOR_SPEND_FOOTER
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SpendViewCell.HEIGHT_FOOTER
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.section].items[indexPath.row]
        
        if let spend = item.spend {
            onSpendPressed?(spend)
        }
        else if let tmark = item.tmark {
            onTMarkPressed?(tmark)
        }
    }
}
