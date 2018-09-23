//
//  ColorsViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 05/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class ColorViewCell: UICollectionViewCell {
    public static let ID = "IconCell"
    public var sample = UIView()
    private let SPACING: CGFloat = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        sample.layer.cornerRadius = 3
        addSubview(sample)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sample.frame = self.bounds
        
        sample.frame.origin.x += SPACING
        sample.frame.origin.y += SPACING
        sample.frame.size.width -= SPACING * 2
        sample.frame.size.height -= SPACING * 2
    }
}

class ColorsViewController: UICollectionViewControllerMod, UICollectionViewDelegateFlowLayout {
    private let COUNTX = 5
    private var cellSize: CGFloat = 60.0

    public var onColorSelected: ((UIColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(ColorViewCell.self, forCellWithReuseIdentifier: ColorViewCell.ID)
        cellSize = collectionView!.contentSize.width / CGFloat(COUNTX)
        
        navigationItem.title = "COLOR".loc()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CATEGORY_COLORS.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconViewCell.ID, for: indexPath) as! ColorViewCell
        cell.sample.backgroundColor = CATEGORY_COLORS[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        onColorSelected?(CATEGORY_COLORS[indexPath.row])
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = COLOR_CAT_SELECT
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
}
