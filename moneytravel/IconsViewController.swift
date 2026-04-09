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
    public var bgcolor = UIColor()
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
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? COLOR_CAT_SELECT : bgcolor
        }
    }
}

class IconsViewController: UICollectionViewControllerMod, UICollectionViewDelegateFlowLayout {
    private let COUNTX = 5
    private var cellSize: CGFloat = 60.0

    public var onIconSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.register(IconViewCell.self, forCellWithReuseIdentifier: IconViewCell.ID)
        navigationItem.title = "ICON".loc()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let newSize = collectionView!.bounds.width / CGFloat(COUNTX)
        
        if newSize != cellSize {
            cellSize = newSize
            collectionView!.reloadData()
        }
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
        cell.bgcolor = getColor(forIndex: indexPath)
        cell.backgroundColor = cell.bgcolor
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        onIconSelected?(ICON_NAMES[indexPath.row])
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
