//
//  DateViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 07/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class DateViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    public var onDatePicked: ((Date) -> Void)?
    private var initDate: Date = Date()
    private var timeOnly: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE".loc(), style: .plain, target: self, action: #selector(saveDate))

        datePicker.datePickerMode = timeOnly ? .time : .dateAndTime
        datePicker.setDate(initDate, animated: true)
        datePicker.minuteInterval = 5
        
        updateDateText()
    }

    public func setup(caption: String, date: Date, timeOnly: Bool = false) {
        navigationItem.title = caption
        self.initDate = date
        self.timeOnly = timeOnly
    }

    private func updateDateText() {
        let formatter = DateFormatter()
        formatter.dateFormat = timeOnly ? "HH:mm" : "HH:mm, dd LLLL"

        textField.text = formatter.string(from: datePicker.date)
    }

    @objc func saveDate() {
        navigationController?.popViewController(animated: true)
        onDatePicked?(datePicker.date)
    }

    @IBAction func datePickerChange(_ sender: UIDatePicker) {
        updateDateText()
    }
}
