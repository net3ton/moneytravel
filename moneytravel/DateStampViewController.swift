//
//  DateMarkViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 13/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class DateStampViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var markPicker: UIPickerView!

    public var onDatePicked: ((HistoryDate) -> Void)?

    private var historyDate: HistoryDate = HistoryDate()
    private var minDate: Date?
    private var maxDate: Date?
    private var customDate: Date = Date()

    private let CUSTOM = 0
    private let TODAY = 1

    private let PREMARKS = [
        "Custom",
        "Today"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if onDatePicked != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDate))
        }

        navigationItem.title = "Date"

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
        let ind = appTimestamps.findIndex(date: historyDate.getDate())
        if ind != -1 {
            markPicker.selectRow(ind + PREMARKS.count, inComponent: 0, animated: false)
        }
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        customDate = sender.date
        markPicker.selectRow(CUSTOM, inComponent: 0, animated: true)
        
        historyDate.setDate(date: customDate)
        updateDateText()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PREMARKS.count + appTimestamps.marks.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < PREMARKS.count {
            return PREMARKS[row]
        }

        return appTimestamps.marks[row - PREMARKS.count].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            historyDate.setDate(date: customDate)
        }
        else if row == 1 {
            historyDate.setDate(date: Date())
        }
        else {
            historyDate.setStamp(stamp: appTimestamps.marks[row - PREMARKS.count])
        }

        updateDateText()
    }
}
