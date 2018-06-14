//
//  DateMarkViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 13/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class DateMarkViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var markPicker: UIPickerView!

    private var historyDate: HistoryDate = HistoryDate()
    private var minDate: Date?
    private var customDate: Date = Date()

    private let CUSTOM = 0
    private let TODAY = 1

    private let PREMARKS = [
        "Custom",
        "Today"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Date"

        datePicker.datePickerMode = .date
        datePicker.minimumDate = minDate
        updateDateText()

        markPicker.delegate = self
        markPicker.dataSource = self
    }

    public func setup(forDate hdate: HistoryDate, min: Date?) {
        historyDate = hdate
        customDate = hdate.getDate()
        minDate = min
    }

    private func updateDateText() {
        textField.text = historyDate.getName()
        datePicker.setDate(historyDate.getDate(), animated: true)
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
        return PREMARKS.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PREMARKS[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            historyDate.setDate(date: customDate)
        }
        else if row == 1 {
            historyDate.setDate(date: Date())
        }

        updateDateText()
    }
}
