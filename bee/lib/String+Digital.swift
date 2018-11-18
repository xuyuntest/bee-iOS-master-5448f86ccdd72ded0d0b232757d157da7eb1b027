//
//  String+Digital.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

extension String {
    
    var digital: String {
        let cs = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted
        return self.components(separatedBy: cs).joined()
    }
}
