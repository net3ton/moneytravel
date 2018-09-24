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
    public static let SPACING: CGFloat = 2.0
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 3
        self.selectedBackgroundView?.backgroundColor = UIColor.white
    }

    public static func getNib() -> UINib {
        return UINib.init(nibName: "CategoryViewCell", bundle: nil)
    }
}


@IBDesignable class CategoriesView: UICollectionView {
    private var lastWidth: CGFloat = 0
    public var onWidthChanged: ((CGFloat, CGFloat) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if lastWidth != self.frame.width {
            lastWidth = self.frame.width
            widthUpdated(lastWidth)
        }
    }
    
    private func widthUpdated(_ width: CGFloat) {
        let CY: CGFloat = 2
        let CX: CGFloat = (UIDevice.current.userInterfaceIdiom != .pad) ? 5 : 6
        
        let cellsize = (width - (CX-1) * CategoryViewCell.SPACING) / CX
        let viewheight = cellsize * CY + (CY-1) * CategoryViewCell.SPACING + 1.0
        
        onWidthChanged?(cellsize, viewheight)
    }
}


class CategoriesViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var cellSize: CGFloat = 32
    public var onCategoryPressed: ((CategoryModel) -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appCategories.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cat = appCategories.categories[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.ID, for: indexPath) as! CategoryViewCell
        cell.name.text = cat.name
        cell.icon.image = cat.icon
        cell.contentView.backgroundColor = cat.color //COLOR_CAT
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
        let cat = appCategories.categories[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)

        UIView.animate(withDuration: 0.5) {
            cell?.contentView.backgroundColor = cat.color //COLOR_CAT
        }
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
