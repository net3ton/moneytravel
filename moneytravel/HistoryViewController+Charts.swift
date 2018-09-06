//
//  HistoryViewControllerCharts.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 01/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import Charts

extension HistoryViewController: ChartViewDelegate {
    /// ChartViewDelegate (bar chart click)
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedDay = Int(entry.x)
        showHistoryDay(ind: selectedDay)
    }

    func updateBarChartView() {
        var chartData: [BarChartDataEntry] = []
        var chartLabels: [String] = []
        for i in 0..<history.count {
            if let historyData = historyDay(ind: i) {
                let entry = BarChartDataEntry(x: Double(i), y: Double(historyData.getSpendBaseSum()))
                chartData.append(entry)
                
                let form = DateFormatter()
                form.dateFormat = "dd.MM"
                chartLabels.append(form.string(from: historyData.date))
            }
        }
        
        class ValueFormatter: IValueFormatter {
            func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                return bnum_to_string(sum: Float(value))
            }
        }
        
        let chartDataSet = BarChartDataSet(values: chartData, label: nil)
        chartDataSet.colors = [COLOR_BAR1, COLOR_BAR2]
        chartDataSet.highlightColor = COLOR_BAR_SELECTED
        chartDataSet.valueFormatter = ValueFormatter()
        
        class AxisLeftFormatter: IAxisValueFormatter {
            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return bnum_to_string(sum: Float(value))
            }
        }
        
        let target = ChartLimitLine(limit: Double(appSettings.dailyMax))
        target.label = "BUDGET".loc()
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
        barchartView.noDataText = "EMPTY".loc()
        barchartView.maxVisibleCount = 10
        barchartView.doubleTapToZoomEnabled = false
        barchartView.highlightValue(x: 0, dataSetIndex: 0)
        
        barchartView.data = BarChartData(dataSets: [chartDataSet])

        for constr in barchartView.constraints {
            if constr.identifier == "height" {
                constr.constant = barchartView.bounds.width / 1.5
            }
        }
    }
    
    func collectCategoryInfo(from days: [DaySpends]) -> [CategoryInfo] {
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
    
    func updatePieChartView() {
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
                return bnum_to_string(sum: Float(value))
            }
        }
        
        let chartDataSet = PieChartDataSet(values: chartData, label: nil)
        chartDataSet.valueFormatter = ValueFormatter()
        
        chartDataSet.colors = chartColors
        chartDataSet.entryLabelColor = UIColor.black
        chartDataSet.valueColors = [COLOR_TEXT_BLUE]
        
        chartDataSet.valueLineColor = COLOR_TEXT_BLUE
        
        chartDataSet.sliceSpace = 1
        chartDataSet.yValuePosition = .outsideSlice
        chartDataSet.valueLinePart1OffsetPercentage = 0.85
        //chartDataSet.valueLinePart1Length = 0.2
        //chartDataSet.valueLinePart2Length = 0.4
        
        piechartView.chartDescription?.enabled = false
        piechartView.legend.enabled = false
        piechartView.noDataText = "Empty"
        piechartView.data = PieChartData(dataSets: [chartDataSet])
        piechartView.rotationWithTwoFingers = true
        
        /// info
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let dictMain = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedStringKey.paragraphStyle: titleParagraphStyle
        ]
        
        let dictDays = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.paragraphStyle: titleParagraphStyle
        ]
        
        let pieInfo: NSMutableAttributedString = NSMutableAttributedString()
        pieInfo.append(NSAttributedString(string: titlebar.sumStr + "\n", attributes: dictMain))
        pieInfo.append(NSAttributedString(string: titlebar.daysStr, attributes: dictDays))
        
        piechartView.centerAttributedText = pieInfo
        
        for constr in piechartView.constraints {
            if constr.identifier == "height" {
                constr.constant = piechartView.bounds.width / 1.2
            }
        }
    }
}
