//
//  CategoryViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 05/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class CategoryViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var colorView: UIView!

    private var name: String?
    private var iconname: String?
    private var color: UIColor?

    private var categoryToSave: CategoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveCategory))
        navigationItem.title = "Category"

        colorView.layer.cornerRadius = 3
        updateInfo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        colorView.backgroundColor = color
    }

    public func setup(category: CategoryModel?) {
        categoryToSave = category

        if let cat = category {
            name = cat.name
            iconname = cat.iconname
            color = cat.color
        }
    }

    private func updateInfo() {
        nameLabel.text = name
        iconView.image = UIImage(named: iconname ?? "")
        colorView.backgroundColor = color
    }

    @objc func saveCategory() {
        if categoryToSave != nil {
            categoryToSave!.name = name ?? ""
            categoryToSave!.iconname = iconname
            categoryToSave!.color = color ?? CATEGORY_DEFAULT
        }
        else {
            appCategories.addNewCategory(name: name ?? "", iconname: iconname ?? "", color: color ?? CATEGORY_DEFAULT)
        }

        appCategories.save()
        navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "category-icon" {
            let iconPicker = segue.destination as! IconsViewController
            iconPicker.onIconSelected = { iconName in
                self.iconname = iconName
                self.updateInfo()
            }
        }
        else if segue.identifier == "category-color" {
            let colorPicker = segue.destination as! ColorsViewController
            colorPicker.onColorSelected = { color in
                self.color = color
                self.updateInfo()
            }
        }
        else if segue.identifier == "category-name" {
            let nameEdit = segue.destination as! TextViewController
            nameEdit.setup(caption: "Name", text: name ?? "")
            nameEdit.onTextEntered = { text in
                self.name = text
                self.updateInfo()
            }
        }
    }
}
