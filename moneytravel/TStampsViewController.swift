//
//  TMarksViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 16/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class TStampViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
}

class TStampsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTimestamp))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @objc func addNewTimestamp() {
        showTimestampInfo(info: nil)
    }

    private func showTimestampInfo(info: MarkModel?) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "tmark-info") as! TStampViewController

        view.setup(mark: info)
        navigationController?.pushViewController(view, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appTimestamps.marks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "HH:mm"
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "dd LLLL yyyy"

        let info = appTimestamps.marks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeMarkCell", for: indexPath) as! TStampViewCell
        cell.nameLabel.text = info.name
        cell.dateLabel.text = formatterDate.string(from: info.date!)
        cell.yearLabel.text = formatterYear.string(from: info.date!)
        cell.backgroundColor = info.color
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = appTimestamps.marks[indexPath.row]
        showTimestampInfo(info: info)
    }
}
