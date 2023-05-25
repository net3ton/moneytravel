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

class HistoryViewController: UIViewControllerMod {
    @IBOutlet weak var dateRangeView: UITableView!
    @IBOutlet weak var historyView: UITableView!
    @IBOutlet weak var categoryView: UITableView!
    @IBOutlet weak var modeSegmentTab: UISegmentedControl!
    @IBOutlet weak var barchartView: BarChartView!
    @IBOutlet weak var piechartView: PieChartView!
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var tailView: UIView!
    
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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK".loc(), style: .plain, target: nil, action: nil)
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
        
        MainViewController.returnFromHistory = true
    }

    //override func didReceiveMemoryWarning() {
    //    super.didReceiveMemoryWarning()
    //}

    @IBAction func onSegmentChanged(_ sender: UISegmentedControl) {
        mode = EHistoryMode(rawValue: sender.selectedSegmentIndex) ?? .History
        changeMode(to: mode)
    }

    func changeMode(to mode: EHistoryMode) {
        modeSegmentTab.selectedSegmentIndex = mode.rawValue
        
        switch mode {
        case .Tendency:
            showHistoryDay(ind: selectedDay)
            barchartView.isHidden = false
            historyView.isHidden = false
            helpLabel.isHidden = false
            helpLabel.text = "HINT_CHARTBAR".loc()

            tailView.isHidden = false
            setTailHeight(view.frame.height)
            
            categoryView.isHidden = true
            piechartView.isHidden = true

        case .Categories:
            categoryView.isHidden = false
            piechartView.isHidden = false
            helpLabel.isHidden = false
            helpLabel.text = "HINT_CHARTPIE".loc()

            tailView.isHidden = false
            setTailHeight(16)
            
            historyView.isHidden = true
            barchartView.isHidden = true

        default: // .History
            showHistory(days: history)
            historyView.isHidden = false

            categoryView.isHidden = true
            barchartView.isHidden = true
            piechartView.isHidden = true
            helpLabel.isHidden = true
            tailView.isHidden = true
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
        historyDelegate!.data = days
        
        for constr in historyView.constraints {
            if constr.identifier == "height" {
                constr.constant = historyDelegate!.getContentHeight()
            }
        }
        
        historyView.reloadData()
    }
    
    func setTailHeight(_ height: CGFloat) {
        for constr in tailView.constraints {
            if constr.identifier == "height" {
                constr.constant = height
            }
        }
    }
    
    func initHistory() {
        historyDelegate = SpendViewDelegate()
        historyDelegate?.onSpendPressed = showSpendInfo
        historyDelegate?.onTMarkPressed = showTMarkInfo
        historyDelegate?.onHeaderPressed = {
            self.historyView.reloadData()
        }
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
    
    @objc func onExport() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let name = String(format: "MoneyTravel_%@.csv", formatter.string(from: Date()))
        
        guard let path = get_temp_path()?.appendingPathComponent(name) else {
            show_info_message(self, msg: "EXPORT_ERROR".loc())
            return
        }
        
        let historyData = AppData(history: self.history)
        guard historyData.exportToCSV().saveTo(path) else {
            show_info_message(self, msg: "EXPORT_ERROR".loc())
            return
        }

        let googleSheet = GoogleSheetActivity(for: history, in: self)
        
        let panel = UIActivityViewController(activityItems: [path], applicationActivities: [googleSheet])
        panel.completionWithItemsHandler = exportComplete
        panel.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(panel, animated: true)
    }
    
    private func exportComplete(activityType: UIActivity.ActivityType?, shared: Bool, items: [Any]?, error: Error?) {
        if let error = error {
            print("Failed to export! ERROR: " + error.localizedDescription)
        }
    }
}


class GoogleSheetActivity: UIActivity {
    private var history: [DaySpends]
    private var vc: UIViewController
    private let HIPImages = "com.oskharkov.moneytravel.gsheet"
    
    init(for history: [DaySpends], in vc: HistoryViewController) {
        self.history = history
        self.vc = vc
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(HIPImages)
    }
    
    override var activityImage: UIImage? {
        get { return UIImage(named: "Google") }
    }
    
    override var activityTitle: String? {
        get { return "Make Spreadsheet" }
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        if !appGoogleDrive.isSpreadsheetsEnabled() {
            show_info_message(vc, msg: "GOOGLE_DISABLED".loc())
            activityDidFinish(true)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let sheetName = String(format: "MoneyTravel (%@)", formatter.string(from: Date()))
        
        appGoogleDrive.makeSpreadsheet(name: sheetName, history: history) { (success) in
            show_info_message(self.vc, msg: success ? "EXPORT_SHT_OK".loc() : "EXPORT_SHT_ERROR".loc())
            self.activityDidFinish(true)
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
        cell.sumBase.text = bnum_to_string(sum: info.daily) + "PER_DAY".loc()
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
