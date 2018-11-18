//
//  TagCategory.swift
//  bee
//
//  Created by Herb on 2018/9/1.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

class TagCategory: Codable {
    
    var cate_id: String = ""
    var name: String = ""
    var sons: [TagCategory]? = []
}
