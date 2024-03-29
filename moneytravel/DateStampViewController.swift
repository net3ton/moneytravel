//
//  DateMarkViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 13/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class DateStampViewController: UIViewControllerMod, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var markPicker: UIPickerView!

    public var onDatePicked: ((HistoryDate) -> Void)?

    private var historyDate: HistoryDate = HistoryDate()
    private var minDate: Date?
    private var maxDate: Date?
    private var customDate: Date = Date()

    private var timestamps: [MarkModel] = appTimestamps.fetchAll()

    private let CUSTOM = 0
    private let TODAY = 1
    private let YESTERDAY = 2
    private let THIS_WEEK = 3
    private let THIS_MONTH = 4

    private let PREMARKS = [
        "T_CUSTOM".loc(),
        "T_TODAY".loc(),
        "T_YESTERDAY".loc(),
        "T_THIS_WEEK".loc(),
        "T_THIS_MONTH".loc()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if onDatePicked != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".loc(), style: .plain, target: self, action: #selector(saveDate))
        }

        navigationItem.title = "DATE".loc()

        datePicker.datePickerMode = .date
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        datePicker.minuteInterval = 5
        updateDateText()

        markPicker.delegate = self
        markPicker.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMark()
    }

    @objc func saveDate() {
        navigationController?.popViewController(animated: true)
        onDatePicked?(historyDate)
    }

    public func setup(forDate hdate: HistoryDate, min: Date?, max: Date?) {
        historyDate = hdate
        customDate = hdate.getDate()
        minDate = min
        maxDate = max
    }

    private func updateDateText() {
        textField.text = historyDate.getName()
        datePicker.setDate(historyDate.getDate(), animated: true)
    }

    private func updateMark() {
        let index = timestamps.firstIndex { (tstamp) -> Bool in
            return tstamp.date == historyDate.getDate()
        }

        if let ind = index {
            markPicker.selectRow(ind + PREMARKS.count, inComponent: 0, animated: false)
        }
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        customDate = sender.date
        markPicker.selectRow(CUSTOM, inComponent: 0, animated: true)
        
        historyDate.setDate(customDate)
        updateDateText()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PREMARKS.count + timestamps.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < PREMARKS.count {
            return PREMARKS[row]
        }

        return timestamps[row - PREMARKS.count].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == CUSTOM {
            historyDate.setDate(customDate)
        }
        else if row == TODAY {
            historyDate.setToday()
        }
        else if row == YESTERDAY {
            historyDate.setDaysAgo(days: 1)
        }
        else if row == THIS_WEEK {
            // we want Monday as first day (Sunday in .gregorian)
            let calendar = Calendar(identifier: .iso8601)
            let startOfWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date())
            historyDate.setDate(startOfWeek.date!)
        }
        else if row == THIS_MONTH {
            let calendar = Calendar(identifier: .iso8601)
            let startOfMonth = calendar.dateComponents([.year, .month], from: Date())
            historyDate.setDate(calendar.date(from: startOfMonth)!)
        }
        else {
            historyDate.setStamp(timestamps[row - PREMARKS.count])
        }

        updateDateText()
    }
}
