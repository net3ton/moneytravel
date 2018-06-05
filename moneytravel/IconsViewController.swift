//
//  IconsViewController.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 05/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

class IconViewCell: UICollectionViewCell {
    public static let ID = "IconCell"
    public var icon = UIImageView()
    private let SPACING: CGFloat = 8.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        icon.frame = self.bounds

        icon.frame.origin.x += SPACING
        icon.frame.origin.y += SPACING
        icon.frame.size.width -= SPACING * 2
        icon.frame.size.height -= SPACING * 2
    }
}

class IconsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let COUNTX = 5
    private var cellSize: CGFloat = 60.0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.register(IconViewCell.self, forCellWithReuseIdentifier: IconViewCell.ID)
        cellSize = collectionView!.contentSize.width / CGFloat(COUNTX)

        //navigationController?.title = "Icons"
    }

    private func getColor(forIndex index: IndexPath) -> UIColor {
        return ((index.row/COUNTX + index.row%COUNTX) % 2 == 1) ? COLOR_SPEND1 : COLOR_SPEND2
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ICON_NAMES.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconViewCell.ID, for: indexPath) as! IconViewCell
        cell.icon.image = UIImage(named: ICON_NAMES[indexPath.row])
        cell.backgroundColor = getColor(forIndex: indexPath)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(ICON_NAMES[indexPath.row])
    }

    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = COLOR_CAT_SELECT
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = getColor(forIndex: indexPath)
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
