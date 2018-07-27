//
//  TitleBar.swift
//  picstore
//
//  Created by Aleksandr Kharkov on 10/07/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class Titlebar: UIView {
    private var labelCaption = UILabel()
    private var labelInfo = UILabel()

    public var sum: Float = 0.0 {
        didSet {
            labelCaption.text = sum_to_string(sum: sum, currency: appSettings.currencyBase)
        }
    }

    public var days: Int = 1 {
        didSet {
            days = max(days, 1)

            let daily: Float = sum / Float(days)
            labelInfo.text = String(format: "%@ / day (%i days)", num_to_string(sum: daily), days)
        }
    }

    init() {
        let width = 200
        let height = 40

        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))

        labelCaption.font = UIFont.boldSystemFont(ofSize: 18)
        labelCaption.textAlignment = .center
        labelCaption.frame = CGRect(x: 0, y: 4, width: width, height: 20)
        self.addSubview(labelCaption)

        labelInfo.font = UIFont.systemFont(ofSize: 12)
        labelInfo.textAlignment = .center
        labelInfo.frame = CGRect(x: 0, y: height - 15, width: width, height: 15)
        self.addSubview(labelInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
