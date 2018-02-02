//
//  Category.swift
//  taskapp
//
//  Created by Fumitaka Hijino on 2018/01/30.
//  Copyright © 2018年 Fumitaka Hijino. All rights reserved.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // カテゴリ名
    @objc dynamic var categoryName = ""
    
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}

