//
//  Categories2ViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 05/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {
    @IBOutlet weak var categoriesView: UICollectionView!
    
    private var categoriesDelegate: CategoriesEditViewDelegate?
    private var gestureRecognizer: UILongPressGestureRecognizer?
    private var viewHeight: CGFloat = 100

    public var onCateggorySelected: ((CategoryModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCategory))
        
        let viewInfo = CategoryViewCell.getCellSizeAndHeight(width: categoriesView.frame.width)

        viewHeight = viewInfo.height
        categoriesDelegate = CategoriesEditViewDelegate(cellSize: viewInfo.csize)
        categoriesDelegate?.onCategoryPressed = editCategory
        categoriesDelegate?.onCategoryMoved = movedCategory
        
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))

        categoriesView.register(CategoryViewCell.getNib(), forCellWithReuseIdentifier: CategoryViewCell.ID)
        categoriesView.delegate = categoriesDelegate
        categoriesView.dataSource = categoriesDelegate
        categoriesView.addGestureRecognizer(gestureRecognizer!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesView.reloadData()
    }
    
    @objc private func addNewCategory() {
        showCategoryInfo(info: nil)
    }

    private func editCategory(category: CategoryModel) {
        showCategoryInfo(info: category)
    }

    private func movedCategory(from: Int, to: Int) {
        appCategories.move(fromPosition: from, to: to)
    }
    
    private func showCategoryInfo(info: CategoryModel?) {
        let sboard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let view = sboard.instantiateViewController(withIdentifier: "category-info") as! CategoryViewController

        view.setup(category: info)
        navigationController?.pushViewController(view, animated: true)
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let index = categoriesView.indexPathForItem(at: gesture.location(in: categoriesView)) {
                categoriesView.beginInteractiveMovementForItem(at: index)
            }
        case .changed:
            categoriesView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
        case .ended:
            categoriesView.endInteractiveMovement()
        default:
            categoriesView.cancelInteractiveMovement()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewHeight + 1.0
    }
}


class CategoriesSelectViewController: UITableViewController {
    @IBOutlet weak var categoriesView: UICollectionView!

    private var categoriesDelegate: CategoriesViewDelegate?
    private var viewHeight: CGFloat = 100

    public var onCateggorySelected: ((CategoryModel) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewInfo = CategoryViewCell.getCellSizeAndHeight(width: categoriesView.frame.width)
        
        viewHeight = viewInfo.height
        categoriesDelegate = CategoriesViewDelegate(cellSize: viewInfo.csize)
        categoriesDelegate?.onCategoryPressed = onCategoryPressed
        
        categoriesView.register(CategoryViewCell.getNib(), forCellWithReuseIdentifier: CategoryViewCell.ID)
        categoriesView.delegate = categoriesDelegate
        categoriesView.dataSource = categoriesDelegate
    }

    private func onCategoryPressed(category: CategoryModel) {
        navigationController?.popViewController(animated: true)
        onCateggorySelected?(category)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewHeight + 1.0
    }
}


class CategoriesEditViewDelegate: CategoriesViewDelegate {
    public var onCategoryMoved: ((Int, Int) -> Void)?

    override init(cellSize: CGFloat) {
        super.init(cellSize: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        onCategoryMoved?(sourceIndexPath.row, destinationIndexPath.row)
    }
}
