//
//  CollectionViewCell.swift
//  Linkage
//
//  Created by LeeJay on 2017/3/13.
//  Copyright © 2017年 LeeJay. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    private lazy var imageV = UIImageView()
    private lazy var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    func configureUI() {
        imageV.frame = CGRect(x: 2, y: 2, width: frame.size.width - 4, height: frame.size.width - 4)
        imageV.contentMode = .scaleAspectFit
        contentView.addSubview(imageV)
        
        nameLabel.frame = CGRect.init(x: 2, y: frame.size.width + 2, width: frame.size.width - 4, height: 20)
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
    }
    
    func setDatas(_ model : SubCategoryModel) {
        
        guard
            let iconUrl = model.iconUrl,
            let name = model.name else { return }
        
        guard let url = URL(string: iconUrl) else { return }
        
        nameLabel.text = name
        imageV.kf.setImage(with: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
