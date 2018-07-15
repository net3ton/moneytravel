//
//  HistoryViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 12/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var dateRangeView: UITableView!
    @IBOutlet weak var historyView: UITableView!

    var titlebar = Titlebar()
    var dateRangeDelegate: DateViewDelegate?
    var historyDelegate: SpendViewDelegate?

    static var historyInterval: HistoryInterval?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titlebar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        if HistoryViewController.historyInterval == nil {
            let interval = HistoryInterval()
            interval.dateTo.setToday()
            interval.dateFrom.setWeekAgo()

            HistoryViewController.historyInterval = interval
        }

        initDateRange()
        initHistory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHistoryView()
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    private func initHistory() {
        historyDelegate = SpendViewDelegate()
        historyDelegate?.onSpendPressed = showSpendInfo

        historyView.register(SpendViewCell.getNib(), forCellReuseIdentifier: SpendViewCell.ID)
        historyView.register(SpendViewHeader.self, forHeaderFooterViewReuseIdentifier: SpendViewHeader.ID)
        historyView.register(SpendViewFooter.self, forHeaderFooterViewReuseIdentifier: SpendViewFooter.ID)
        historyView.delegate = historyDelegate
        historyView.dataSource = historyDelegate
    }

    private func showSpendInfo(spend: SpendModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "spend-info") as! SpendViewController
        
        view.setup(sinfo: spend)
        navigationController?.pushViewController(view, animated: true)
    }

    private func updateHistoryView() {
        let history = appSpends.fetch(for: HistoryViewController.historyInterval!)
        historyDelegate?.data = history
        updateHeader(with: history)

        for constr in historyView.constraints {
            if constr.identifier == "height" {
                constr.constant = historyDelegate!.getContentHeight()
            }
        }
        
        dateRangeView.reloadData()
        historyView.reloadData()
    }

    private func initDateRange() {
        dateRangeDelegate = DateViewDelegate()
        dateRangeDelegate?.onDatePressed = onDateSelect
        dateRangeDelegate?.historyInterval = HistoryViewController.historyInterval!

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

    private func updateHeader(with history: [DaySpends]) {
        var sum: Float = 0.0
        for dailySpend in history {
            for sinfo in dailySpend.spends {
                if sinfo.bcurrency == appSettings.currencyBase {
                    sum += sinfo.bsum
                }
            }
        }

        titlebar.sum = sum
        titlebar.daily = sum / Float(history.count)
    }
}


class HistoryInterval {
    var dateFrom: HistoryDate = HistoryDate()
    var dateTo: HistoryDate = HistoryDate()

    subscript(index: Int) -> (date: HistoryDate, minDate: Date?, label: String) {
        get {
            if index == 0 {
                return (date: dateFrom, minDate: nil, label: "From")
            }
            
            return (date: dateTo, minDate: dateFrom.getDate(), label: "To")
        }
    }

    var count: Int {
        get {
            return 2
        }
    }
}


class DateViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    public var onDatePressed: ((HistoryDate, Date?) -> Void)?
    public var historyInterval: HistoryInterval?

    let HEIGHT: CGFloat = 44.0

    func getContentHeight() -> CGFloat {
        return HEIGHT * CGFloat(historyInterval!.count)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyInterval!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = historyInterval![indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath)
        cell.textLabel?.text = info.label
        cell.detailTextLabel?.text = info.date.getName()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HEIGHT
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = historyInterval![indexPath.row]
        onDatePressed?(info.date, info.minDate)
    }
}
