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

    private var name: String = ""
    private var iconname: String = ""
    private var color: UIColor = CATEGORY_DEFAULT

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
            name = cat.name!
            iconname = cat.iconname!
            color = cat.color
        }
    }

    private func updateInfo() {
        nameLabel.text = name
        iconView.image = UIImage(named: iconname)
        colorView.backgroundColor = color
    }

    @objc func saveCategory() {
        if categoryToSave != nil {
            categoryToSave!.name = name
            categoryToSave!.iconname = iconname
            categoryToSave!.color = color
            appCategories.save()
        }
        else {
            appCategories.add(name: name, iconname: iconname, color: color)
        }

        navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return categoryToSave == nil ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 && categoryToSave != nil {
            let removeController = UIAlertController(title: nil, message: "Delete the category? It can't be undone", preferredStyle: .actionSheet);
            
            removeController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
                appCategories.delete(category: self.categoryToSave!)
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
            nameEdit.setup(caption: "Name", text: name)
            nameEdit.onTextEntered = { text in
                self.name = text
                self.updateInfo()
            }
        }
    }
}
