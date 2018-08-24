//
//  HistoryViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 12/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import Charts

enum EHistoryMode: Int {
    case History = 0
    case Tendency = 1
    case Categories = 2
}

class HistoryViewController: UIViewController {
    @IBOutlet weak var dateRangeView: UITableView!
    @IBOutlet weak var historyView: UITableView!
    @IBOutlet weak var categoryView: UITableView!
    @IBOutlet weak var barchartView: BarChartView!
    @IBOutlet weak var piechartView: PieChartView!
    @IBOutlet weak var helpLabel: UILabel!
    
    var dateRangeDelegate: DateViewDelegate?
    var historyDelegate: SpendViewDelegate?
    var categoryDelegate: CategoryViewDelegate?

    var titlebar = Titlebar()
    var history: [DaySpends] = []
    var selectedDay: Int = -1
    var mode: EHistoryMode = .History

    static var historyInterval: HistoryInterval?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titlebar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Export"), style: .plain, target: self, action: #selector(onExport))

        if HistoryViewController.historyInterval == nil {
            let interval = HistoryInterval()
            interval.dateTo.setToday()
            interval.dateFrom.setWeekAgo()

            HistoryViewController.historyInterval = interval
        }

        initDateRange()
        initHistory()
        initCategories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedDay = -1
        history = appSpends.fetch(for: HistoryViewController.historyInterval!)
        updateHeader(with: history)
        dateRangeView.reloadData()

        updateBarChartView()
        updatePieChartView()

        changeMode(to: mode)
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    @IBAction func onSegmentChanged(_ sender: UISegmentedControl) {
        mode = EHistoryMode(rawValue: sender.selectedSegmentIndex) ?? .History
        changeMode(to: mode)
    }

    func changeMode(to mode: EHistoryMode) {
        switch mode {
        case .Tendency:
            barchartView.isHidden = false
            historyView.isHidden = false
            showHistoryDay(ind: selectedDay)
            helpLabel.isHidden = (selectedDay != -1)

            categoryView.isHidden = true
            piechartView.isHidden = true

        case .Categories:
            categoryView.isHidden = false
            piechartView.isHidden = false

            historyView.isHidden = true
            barchartView.isHidden = true
            helpLabel.isHidden = true

        default: // .History
            historyView.isHidden = false
            showHistory(days: history)

            categoryView.isHidden = true
            barchartView.isHidden = true
            piechartView.isHidden = true
            helpLabel.isHidden = true
        }
    }

    func historyDay(ind: Int) -> DaySpends? {
        if ind < 0 || ind >= history.count {
            return nil
        }
        
        let invertedInd = history.count - ind - 1
        return history[invertedInd]
    }
    
    func showHistoryDay(ind: Int) {
        let day = historyDay(ind: ind)
        showHistory(days: (day != nil) ? [day!] : [])
    }
    
    func showHistory(days: [DaySpends]) {
        let shouldUpdateConstraint = (days.count != historyDelegate!.data.count)
        historyDelegate!.data = days
        
        for constr in historyView.constraints {
            if constr.identifier == "height" {
                let newHeight = historyDelegate!.getContentHeight()
                
                if newHeight > constr.constant || shouldUpdateConstraint {
                    constr.constant = historyDelegate!.getContentHeight()
                }
            }
        }
        
        historyView.reloadData()
    }
    
    func initHistory() {
        historyDelegate = SpendViewDelegate()
        historyDelegate?.onSpendPressed = showSpendInfo
        historyDelegate?.onTMarkPressed = showTMarkInfo
        historyDelegate?.initClasses(for: historyView)

        historyView.delegate = historyDelegate
        historyView.dataSource = historyDelegate
    }

    func showSpendInfo(spend: SpendModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "spend-info") as! SpendViewController
        
        view.setup(sinfo: spend)
        navigationController?.pushViewController(view, animated: true)
    }

    func showTMarkInfo(tmark: MarkModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "tmark-info") as! TStampViewController
        
        view.setup(mark: tmark)
        navigationController?.pushViewController(view, animated: true)
    }

    func initDateRange() {
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

    func onDateSelect(hdate: HistoryDate, mindate: Date?) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "hdate-picker") as! DateStampViewController

        view.setup(forDate: hdate, min: mindate, max: nil)
        navigationController?.pushViewController(view, animated: true)
    }

    func initCategories() {
        categoryDelegate = CategoryViewDelegate()

        categoryView.register(SpendViewCell.getNib(), forCellReuseIdentifier: SpendViewCell.ID)
        categoryView.delegate = categoryDelegate
        categoryView.dataSource = categoryDelegate
    }

    func updateHeader(with history: [DaySpends]) {
        var sum: Float = 0.0
        for dailySpend in history {
            sum += dailySpend.getSpendBaseSum()
        }

        titlebar.sum = sum
        titlebar.days = history.count
    }
    
    private func showMessage(title: String, message: String) {
        let msg = UIAlertController(title: title, message: message, preferredStyle: .alert)
        msg.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(msg, animated: true, completion: nil)
    }
    
    @objc func onExport() {
        func getExportFileName() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm"
            return String(format: "MoneyTravel_%@.csv", formatter.string(from: Date()))
        }
        
        let export = UIAlertController(title: "Export selected history to:", message: nil, preferredStyle: .actionSheet)
        
        let spreadsheet = UIAlertAction(title: "Google Spreadsheet", style: .default, handler: { (action) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            let sheetName = String(format: "MoneyTravel (%@)", formatter.string(from: Date()))
            
            appGoogleDrive.makeSpreadsheet(name: sheetName, history: self.history) { (success) in
                let messageOk = "Spreadsheed created."
                let messageFaild = "An error occurred while exporting to spreadsheed."
                
                let titleOk = "Export complete"
                let titleFailed = "Export failed"
                
                self.showMessage(title: success ? titleOk : titleFailed, message: success ? messageOk : messageFaild)
            }
        })
        
        let googleCSV = UIAlertAction(title: "Google Drive (cvs)", style: .default, handler: { (action) in
            let historyData = AppData(history: self.history)
            let dataCSV = historyData.exportToCSV()
            let fileName = getExportFileName()

            appGoogleDrive.uploadToRoot(data: dataCSV, filename: fileName, mime: .csv) { (success) in
                let messageOk = "CSV file uploaded to google drive."
                let messageFaild = "An error occurred while uploading to google drive."
                
                let titleOk = "Export complete"
                let titleFailed = "Export failed"
                
                self.showMessage(title: success ? titleOk : titleFailed, message: success ? messageOk : messageFaild)
            }
        })

        let icloudCSV = UIAlertAction(title: "iCloud (cvs)", style: .default, handler: { (action) in
            let historyData = AppData(history: self.history)
            let fileName = getExportFileName()
            
            let success = historyData.saveToCSV(name: fileName, location: .icloud)
            
            let messageOk = "CSV file created in iCloud."
            let messageFaild = "An error occurred while exporting."
            
            let titleOk = "Export complete"
            let titleFailed = "Export failed"
            
            self.showMessage(title: success ? titleOk : titleFailed, message: success ? messageOk : messageFaild)
        })
        
        let localCSV = UIAlertAction(title: "iTunes Shared Folder (cvs)", style: .default, handler: { (action) in
            let historyData = AppData(history: self.history)
            let fileName = getExportFileName()
            
            let success = historyData.saveToCSV(name: fileName, location: .sharedFolder)
            
            let messageOk = "CSV file created in iTunes shared folder."
            let messageFaild = "An error occurred while exporting."
            
            let titleOk = "Export complete"
            let titleFailed = "Export failed"
            
            self.showMessage(title: success ? titleOk : titleFailed, message: success ? messageOk : messageFaild)
        })

        spreadsheet.setValue(UIImage(named: "Google"), forKey: "image")
        spreadsheet.setValue(0, forKey: "titleTextAlignment")
        googleCSV.setValue(UIImage(named: "Google"), forKey: "image")
        googleCSV.setValue(0, forKey: "titleTextAlignment")
        icloudCSV.setValue(UIImage(named: "iCloud"), forKey: "image")
        icloudCSV.setValue(0, forKey: "titleTextAlignment")
        localCSV.setValue(UIImage(named: "iTunes"), forKey: "image")
        localCSV.setValue(0, forKey: "titleTextAlignment")

        export.addAction(spreadsheet)
        export.addAction(googleCSV)
        export.addAction(icloudCSV)
        export.addAction(localCSV)
        export.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        export.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(export, animated: true, completion: nil)
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


struct CategoryInfo {
    var category: CategoryModel
    var sum: Float
    var daily: Float
    var color: UIColor
}

class CategoryViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    public var data: [CategoryInfo] = []

    func getContentHeight() -> CGFloat {
        return CGFloat(data.count) * SpendViewCell.HEIGHT
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = data[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: SpendViewCell.ID, for: indexPath) as! SpendViewCell
        cell.icon.image = info.category.icon
        cell.comment.text = info.category.name
        cell.sum.text = bsum_to_string(sum: info.sum)
        cell.sumBase.text = bnum_to_string(sum: info.daily) + " / day"
        cell.backgroundColor = (indexPath.row % 2 == 1) ? COLOR_SPEND2 : COLOR_SPEND1
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SpendViewCell.HEIGHT
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
