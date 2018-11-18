//
//  User.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

enum Gender: Int, Codable {
    case unkown
    case male
    case female
}

class User: Codable, Request {
    
    var nickname: String = ""
    var gender: Gender? = .male
    var avatar: String? = ""
    var openid: String? = ""
    var country: String? = ""
    var province: String? = ""
    var city: String? = ""
    var token: String? = ""
    
    var postDictionary: [String: Any] {
        var dictionary = self.dictionary
        dictionary.removeValue(forKey: "token")
        return dictionary
    }
}
