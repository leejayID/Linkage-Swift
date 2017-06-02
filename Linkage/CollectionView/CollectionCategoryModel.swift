//
//  CollectionCategoryModel.swift
//  Linkage
//
//  Created by LeeJay on 2017/3/10.
//  Copyright © 2017年 LeeJay. All rights reserved.
//

import UIKit

class CollectionCategoryModel: NSObject {
    
    var name : String?
    var subcategories : [SubCategoryModel]?

    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        
        if key == "subcategories" {
            subcategories = Array()
            guard let datas = value as? [[String : Any]] else { return }
            for dict in datas {
                let subModel = SubCategoryModel(dict: dict)
                subcategories?.append(subModel)
            }
        } else {
            super.setValue(value, forKey: key)
        }
        
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

}

class SubCategoryModel: NSObject {
    
    var iconUrl : String?
    var name : String?
    
    init(dict : [String : Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "icon_url" {
            guard let icon = value as? String else { return }
            iconUrl = icon
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
