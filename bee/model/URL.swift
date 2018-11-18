//
//  URL.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

let qiniuHost = URL(string: "https://f1.beeprt.com/")

extension String {
    
    var qiniuURL: URL? {
        if self.range(of: "http://")?.lowerBound == self.startIndex || self.range(of: "https://")?.lowerBound == self.startIndex {
            return URL(string: self)
        }
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self, relativeTo: qiniuHost)
    }
}
