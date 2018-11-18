//
//  ExcelManager.swift
//  bee
//
//  Created by Herb on 2018/8/25.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class FilesManager {

    static let shared = FilesManager()
    
    private init () {}
    
    func listExcels () -> [URL] {
        let fileManager = FileManager.default
        let documentUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentUrl = documentUrls.first else { return [] }
        let inboxUrl = documentUrl.appendingPathComponent("Inbox")
        guard let subPaths = try? fileManager.contentsOfDirectory(at: inboxUrl, includingPropertiesForKeys: nil, options: []) else {
            return []
        }
        return subPaths.filter({ (url) -> Bool in
            let ext = url.pathExtension.lowercased()
            return ext == "xlsx" || ext == "xls"
        })
    }
}
