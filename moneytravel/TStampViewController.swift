//
//  TMarkViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 16/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class TStampViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var colorView: UIView!

    private var name: String = ""
    private var date: Date = Date()
    private var color: UIColor = CATEGORY_DEFAULT

    private var markToSave: MarkModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveMark))
        navigationItem.title = "Timestamp"

        colorView.layer.cornerRadius = 3
        updateInfo()
    }

    @objc func backButton() {
        print("asd")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        colorView.backgroundColor = color
    }

    public func setup(mark: MarkModel?) {
        markToSave = mark
        
        if let mk = mark {
            name = mk.name!
            date = mk.date!
            color = mk.color
        }
    }

    private func updateInfo() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd LLLL yyyy"

        nameLabel.text = name
        dateLabel.text = formatter.string(from: date)
        colorView.backgroundColor = color
    }

    @objc func saveMark() {
        if markToSave != nil {
            markToSave!.name = name
            markToSave!.date = date
            markToSave!.color = color
            appTimestamps.save()
        }
        else {
            appTimestamps.add(name: name, date: date, color: color)
        }

        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return markToSave == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 && markToSave != nil {
            let removeController = UIAlertController(title: nil, message: "Delete the timestamp? It can't be undone", preferredStyle: .actionSheet);

            removeController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                appTimestamps.delete(stamp: self.markToSave!)
            }))
            removeController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(removeController, animated: true) {
                if let selected = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selected, animated: true)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mark-date" {
            let datePicker = segue.destination as! DateViewController
            datePicker.onDatePicked = { date in
                self.date = date
                self.updateInfo()
            }
        }
        else if segue.identifier == "mark-color" {
            let colorPicker = segue.destination as! ColorsViewController
            colorPicker.onColorSelected = { color in
                self.color = color
                self.updateInfo()
            }
        }
        else if segue.identifier == "mark-name" {
            let nameEdit = segue.destination as! TextViewController
            nameEdit.setup(caption: "Name", text: name)
            nameEdit.onTextEntered = { text in
                self.name = text
                self.updateInfo()
            }
        }
    }
}
