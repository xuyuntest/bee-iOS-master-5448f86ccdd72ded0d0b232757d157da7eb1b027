//
//  Response.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

protocol Request {
    var postDictionary: [String: Any] { get }
}

class QiniuToken: Codable {
    var token: String = ""
}

class Response: Codable, Request {
    var code: Int? = 0
    var status: Int? = 200
    var message: String? = ""
    
    var postDictionary: [String: Any] {
        var dictionary = self.dictionary
        dictionary.removeValue(forKey: "code")
        dictionary.removeValue(forKey: "status")
        dictionary.removeValue(forKey: "message")
        return dictionary
    }
}
