//
//  Template.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

class TagWithInfo: Codable {
    
    var template_id: String? = ""
    var name: String = ""
    var preview: String = ""
    var `public`: Int? = 0
    var data: Tag? = nil
    var self_created: Bool? = false
    var width: Float? = 400
    var height: Float? = 300
    
    var isPublic: Bool {
        if let p = self.public {
            return p > 0
        }
        return false
    }
    
    private enum CodingKeys: String, CodingKey {
        case template_id
        case name
        case preview
        case `public`
        case data
        case self_created
        case width
        case height
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(String.self, forKey: .template_id), let nonNil = value {
            self.template_id = nonNil
        }
        
        if let value = try? container.decodeIfPresent(String.self, forKey: .name), let nonNil = value {
            self.name = nonNil
        }
        
        if let value = try? container.decodeIfPresent(String.self, forKey: .preview), let nonNil = value {
            self.preview = nonNil
        }
        
        if let value = try? container.decodeIfPresent(Int.self, forKey: .public), let nonNil = value {
            self.public = nonNil
        }
        
        if let value = try? container.decodeIfPresent(Tag.self, forKey: .data), let nonNil = value {
            self.data = nonNil
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .self_created), let nonNil = value {
            self.self_created = nonNil
        }
        
        if let value = try? container.decodeIfPresent(Float.self, forKey: .width), let nonNil = value {
            self.width = nonNil
        } else {
            if let value = try? container.decodeIfPresent(String.self, forKey: .width), let nonNil = Float(value ?? "") {
                self.width = nonNil
            }
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .height), let nonNil = value {
            self.height = nonNil
        } else {
            if let value = try? container.decodeIfPresent(String.self, forKey: .height), let nonNil = Float(value ?? "") {
                self.height = nonNil
            }
        }
    }
    
    init () {
    }
    
    func clone() -> TagWithInfo {
        let data = try! JSONEncoder().encode(self)
        let decoder = JSONDecoder()
        let copy = try! decoder.decode(TagWithInfo.self, from: data)
        return copy
    }
}

class TagWithInfos: Codable {
    var templates: [TagWithInfo]
}
