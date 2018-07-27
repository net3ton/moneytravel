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

class HistoryViewController: UIViewController, ChartViewDelegate {
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

    /// ChartViewDelegate (bar chart click)
    internal func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        helpLabel.isHidden = true
        selectedDay = Int(entry.x)
        showHistoryDay(ind: selectedDay)
    }

    private func showHistoryDay(ind: Int) {
        let day = historyDay(ind: ind)
        showHistory(days: (day != nil) ? [day!] : [])
    }
    
    private func historyDay(ind: Int) -> DaySpends? {
        if ind < 0 || ind >= history.count {
            return nil
        }

        let invertedInd = history.count - ind - 1
        return history[invertedInd]
    }

    private func updateBarChartView() {
        var chartData: [BarChartDataEntry] = []
        var chartLabels: [String] = []
        for i in 0..<history.count {
            if let historyData = historyDay(ind: i) {
                let entry = BarChartDataEntry(x: Double(i), y: Double(historyData.getSpendSum()))
                chartData.append(entry)

                let form = DateFormatter()
                form.dateFormat = "dd.MM"
                chartLabels.append(form.string(from: historyData.date))
            }
        }

        class ValueFormatter: IValueFormatter {
            func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                return num_to_string(sum: Float(value))
            }
        }

        let chartDataSet = BarChartDataSet(values: chartData, label: nil)
        chartDataSet.colors = [COLOR_SPEND1, COLOR_SPEND_HEADER]
        chartDataSet.highlightColor = UIColor.red
        chartDataSet.valueFormatter = ValueFormatter()

        class AxisLeftFormatter: IAxisValueFormatter {
            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return num_to_string(sum: Float(value))
            }
        }

        let target = ChartLimitLine(limit: Double(appSettings.dailyMax))
        target.label = "Budget"
        target.lineColor = COLOR_TEXT_BLUE

        barchartView.rightAxis.drawLabelsEnabled = false
        barchartView.rightAxis.drawGridLinesEnabled = false
        barchartView.rightAxis.axisLineColor = COLOR_SPEND_HEADER

        barchartView.leftAxis.axisMinimum = 0
        barchartView.leftAxis.gridColor = COLOR_SPEND_HEADER
        barchartView.leftAxis.valueFormatter = AxisLeftFormatter()
        barchartView.leftAxis.addLimitLine(target)

        class AxisXFormatter: IAxisValueFormatter {
            private var labels: [String]!

            init(_ labels: [String]) {
                self.labels = labels
            }

            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return labels[Int(value)]
            }
        }

        barchartView.chartDescription?.enabled = false
        barchartView.xAxis.drawGridLinesEnabled = false
        barchartView.xAxis.valueFormatter = AxisXFormatter(chartLabels)
        barchartView.xAxis.labelPosition = .bottom
        barchartView.xAxis.granularity = 1

        barchartView.delegate = self

        barchartView.legend.enabled = false
        barchartView.noDataText = "Empty"
        barchartView.maxVisibleCount = 10
        barchartView.doubleTapToZoomEnabled = false

        barchartView.data = BarChartData(dataSets: [chartDataSet])

        for constr in barchartView.constraints {
            if constr.identifier == "height" {
                constr.constant = barchartView.bounds.width / 1.5
            }
        }
    }

    private func collectCategoryInfo(from days: [DaySpends]) -> [CategoryInfo] {
        var summary = [CategoryModel:Float]()
        for daily in days {
            for spend in daily.spends {
                if let category = spend.category {
                    let spendSum = summary[category]
                    summary[category] = spend.bsum + ((spendSum != nil) ? spendSum! : 0.0)
                }
            }
        }

        let sortedSummary = summary.sorted { (item1, item2) -> Bool in
            return item1.value > item2.value
        }

        var categoryData: [CategoryInfo] = []
        for item in sortedSummary.enumerated() {
            let ind = CGFloat(item.offset + 1)
            let color = UIColor(red:(1.0 - ind * 0.06), green:(1.0 - ind * 0.02), blue:(1.0 - ind * 0.06), alpha:1.0)
            let daily = item.element.value / Float(days.count)
            let info = CategoryInfo(category: item.element.key, sum: item.element.value, daily: daily, color: color)
            categoryData.append(info)
        }

        return categoryData
    }

    private func updatePieChartView() {
        let categoryData = collectCategoryInfo(from: history)
        categoryDelegate?.data = categoryData

        for constr in categoryView.constraints {
            if constr.identifier == "height" {
                constr.constant = categoryDelegate!.getContentHeight()
            }
        }

        categoryView.reloadData()

        var chartData: [PieChartDataEntry] = []
        var chartColors: [UIColor] = []

        for i in 0..<categoryData.count {
            /// make small values max distributed
            let item = (i % 2 == 0) ? categoryData[i/2] : categoryData[categoryData.count - i/2 - 1]
            let entry = PieChartDataEntry(value: Double(item.sum), label: item.category.name ?? "")
            chartData.append(entry)
            chartColors.append(item.color)
        }

        class ValueFormatter: IValueFormatter {
            func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                return num_to_string(sum: Float(value))
            }
        }

        let chartDataSet = PieChartDataSet(values: chartData, label: nil)
        chartDataSet.valueFormatter = ValueFormatter()

        chartDataSet.colors = chartColors
        chartDataSet.entryLabelColor = UIColor.black
        chartDataSet.valueColors = [COLOR_TEXT_BLUE]

        chartDataSet.valueLineColor = COLOR_TEXT_BLUE

        chartDataSet.sliceSpace = 2
        chartDataSet.yValuePosition = .outsideSlice
        chartDataSet.valueLinePart1OffsetPercentage = 0.85
        //chartDataSet.valueLinePart1Length = 0.2
        //chartDataSet.valueLinePart2Length = 0.4

        piechartView.chartDescription?.enabled = false
        piechartView.legend.enabled = false
        piechartView.noDataText = "Empty"
        piechartView.data = PieChartData(dataSets: [chartDataSet])
        //piechartView.isUserInteractionEnabled = true

        for constr in piechartView.constraints {
            if constr.identifier == "height" {
                constr.constant = piechartView.bounds.width / 1.2
            }
        }
    }

    @IBAction func onSegmentChanged(_ sender: UISegmentedControl) {
        mode = EHistoryMode(rawValue: sender.selectedSegmentIndex) ?? .History
        changeMode(to: mode)
    }

    private func changeMode(to mode: EHistoryMode) {
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

    private func initHistory() {
        historyDelegate = SpendViewDelegate()
        historyDelegate?.onSpendPressed = showSpendInfo
        historyDelegate?.onTMarkPressed = showTMarkInfo
        historyDelegate?.initClasses(for: historyView)

        historyView.delegate = historyDelegate
        historyView.dataSource = historyDelegate
    }

    private func showSpendInfo(spend: SpendModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "spend-info") as! SpendViewController
        
        view.setup(sinfo: spend)
        navigationController?.pushViewController(view, animated: true)
    }

    private func showTMarkInfo(tmark: MarkModel) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "tmark-info") as! TStampViewController
        
        view.setup(mark: tmark)
        navigationController?.pushViewController(view, animated: true)
    }

    private func showHistory(days: [DaySpends]) {
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

    private func initCategories() {
        categoryDelegate = CategoryViewDelegate()

        categoryView.register(SpendViewCell.getNib(), forCellReuseIdentifier: SpendViewCell.ID)
        categoryView.delegate = categoryDelegate
        categoryView.dataSource = categoryDelegate
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
        titlebar.days = history.count
    }

    @objc func onExport() {
        let export = UIAlertController(title: "Export selected interval", message: nil, preferredStyle: .actionSheet);

        export.addAction(UIAlertAction(title: "Google Spreadsheet", style: .default, handler: { (action) in
        }))

        export.addAction(UIAlertAction(title: "Google Drive (json)", style: .default, handler: { (action) in
        }))

        export.addAction(UIAlertAction(title: "iTunes Shared Folder (json)", style: .default, handler: { (action) in
            let historyData = AppData(history: self.history)
            historyData.exportToJSON(name: AppData.getExportName())
        }))

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
        cell.sum.text = sum_to_string(sum: info.sum, currency: appSettings.currencyBase)
        cell.sumBase.text = num_to_string(sum: info.daily) + " / day"
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
