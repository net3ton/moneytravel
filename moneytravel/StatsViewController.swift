//
//  StatsViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 12/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    @IBOutlet weak var dateRangeView: UITableView!

    var dateRangeDelegate: DateViewDelegate?
    var statsInterval: HistoryInterval = HistoryInterval()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statsInterval.dateTo.setToday()
        statsInterval.dateFrom.setWeekAgo()
        
        initDateRange()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dateRangeView.reloadData()
    }
    
    private func initDateRange() {
        dateRangeDelegate = DateViewDelegate()
        dateRangeDelegate?.onDatePressed = onDateSelect
        dateRangeDelegate?.historyInterval = statsInterval
        
        dateRangeView.delegate = dateRangeDelegate
        dateRangeView.dataSource = dateRangeDelegate
        
        for constr in dateRangeView.constraints {
            if constr.identifier == "height" {
                constr.constant = dateRangeDelegate!.getContentHeight()
            }
        }
    }

    private func onDateSelect(hdate: HistoryDate, mindate: Date?) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "hdate-picker") as! DateStampViewController
        
        view.setup(forDate: hdate, min: mindate, max: nil)
        navigationController?.pushViewController(view, animated: true)
    }
}
