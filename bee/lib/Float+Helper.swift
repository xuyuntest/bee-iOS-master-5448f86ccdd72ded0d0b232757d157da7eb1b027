//
//  Float+Helper.swift
//  bee
//
//  Created by Herb on 2018/9/25.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

extension Float {
    
    var shortStr: String {
        let str = String(format: "%.2f", self)
        return str.replacingOccurrences(of: ".00", with: "")
    }
}
