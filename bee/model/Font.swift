//
//  Font.swift
//  bee
//
//  Created by Herb on 2018/10/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

class Font: Codable {
    var key: String = ""
    var hash: String = ""
    var name: String = ""
    var name_en: String = ""
    
    var progress: Double? = -1
    
    var localizedName: String {
        if API.isChinese {
            return self.name
        }
        return self.name_en
    }
}
