//
//  CategoryViewCell.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 22/05/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class CategoryViewCell: UICollectionViewCell {
    public static let ID = "CategoryCell"
    public static let COUNTX = 5
    public static let COUNTY = 2
    public static let SPACING: CGFloat = 2.0
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 3
        self.selectedBackgroundView?.backgroundColor = UIColor.white
    }

    public static func getCellSizeAndHeight(width: CGFloat) -> (csize: CGFloat, height: CGFloat) {
        let cellsize = (width - CGFloat(CategoryViewCell.COUNTX-1) * CategoryViewCell.SPACING) / CGFloat(CategoryViewCell.COUNTX)
        let viewheight = cellsize * CGFloat(CategoryViewCell.COUNTY) + CGFloat(CategoryViewCell.COUNTY-1) * CategoryViewCell.SPACING

        return (csize: cellsize, height: viewheight)
    }
    
    public static func getNib() -> UINib {
        return UINib.init(nibName: "CategoryViewCell", bundle: nil)
    }
}

class CategoriesViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var cellSize: CGFloat
    public var onCategoryPressed: ((CategoryModel) -> Void)?
    
    init(cellSize: CGFloat) {
        self.cellSize = cellSize
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appCategories.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cat = appCategories.categories[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.ID, for: indexPath) as! CategoryViewCell
        cell.name.text = cat.name
        cell.icon.image = cat.icon
        cell.contentView.backgroundColor = COLOR_CAT
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onCategoryPressed?(appCategories.categories[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = COLOR_CAT_SELECT
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = COLOR_CAT
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CategoryViewCell.SPACING
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CategoryViewCell.SPACING
    }
}
