//
//  FileCache.swift
//  bee
//
//  Created by Herb on 2018/9/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation
import Alamofire

class FileCacherBase {
    let storage: DiskStorage
    
    fileprivate init (_ name: String) {
        try! storage = DiskStorage(name)
    }
    
    func cleanup () {
        try? storage.removeAll()
    }
    
    public func isExist(url: URL, ext: String) -> Bool {
        let key = url.lastPathComponent
        let cacheKey = "\(key).\(ext)"
        let filePath: String? = self.storage.entry(forKey: cacheKey)
        return filePath != nil
    }
    
    public func cacheLocalFile(url: URL, ext: String, progress: DataRequest.ProgressHandler? = nil, callback: @escaping ((String?, String?, Error?) -> Void)) {
        if url.isFileURL {
            guard let data = try? Data(contentsOf: url) else { return }
            API.shared.upload(data) { (key, error) in
                if let key = key {
                    let cacheKey = "\(key).\(ext)"
                    do {
                        try self.storage.setObject(data, forKey: cacheKey)
                        callback(key, self.storage.entry(forKey: cacheKey), nil)
                    } catch {
                        callback(nil, nil, error)
                    }
                } else {
                    callback(nil, nil, error)
                }
            }
        } else {
            let key = url.lastPathComponent
            let cacheKey = "\(key).\(ext)"
            if let filePath: String = self.storage.entry(forKey: cacheKey) {
                callback(key, filePath, nil)
                return
            }
            let req = Alamofire.request(url)
            if let progress = progress {
                req.downloadProgress(closure: progress)
            }
            req.responseData { (response) in
                if let data = response.value {
                    do {
                        try self.storage.setObject(data, forKey: cacheKey)
                        callback(key, self.storage.entry(forKey: cacheKey), nil)
                    } catch {
                        callback(nil, nil, error)
                    }
                } else {
                    callback(nil, nil, response.error)
                }
            }
        }
    }
}

class FileCacher: FileCacherBase {
    static let shared = FileCacher()
    
    private init () {
        super.init("File")
    }
}

class FontCacher: FileCacherBase {
    
    static let shared = FontCacher()
    
    private var cachedFontFamilies = Set<String>()
    public var fontFamilies: [String] {
        var familyNames = UIFont.familyNames.filter { (familyName) -> Bool in
            return !cachedFontFamilies.contains(familyName)
        }
        familyNames.insert(contentsOf: cachedFontFamilies, at: 0)
        return familyNames
    }
    
    public var namingMap: [String: Font] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "font_naming_map") else { return [:] }
            let namingMap = (try? JSONDecoder().decode([String: Font].self, from: data)) ?? [:]
            return namingMap
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "font_naming_map")
            }
        }
    }
    
    private init () {
        super.init("Font")
    }
    
    public func reversedFontName(_ text: String) -> String {
        if text == NSLocalizedString("系统默认", comment: "系统默认") {
            return ""
        }
        for (k, v) in namingMap {
            if v.name == text {
                return k
            }
        }
        return text
    }
    
    public func isExist(font: Font) -> Bool {
        guard let url = font.key.qiniuURL else {
            return false
        }
        return super.isExist(url: url, ext: url.pathExtension)
    }
    
    public func cacheFont(font: Font, progress: DataRequest.ProgressHandler? = nil, callback: @escaping ((String?, String?, Error?) -> Void)) {
        guard let url = font.key.qiniuURL else {
            callback(nil, nil, SimpleError.string(NSLocalizedString("无效字体", comment: "无效字体")))
            return
        }
        return super.cacheLocalFile(url: url, ext: url.pathExtension, progress: progress) { (key, filePath, error) in
            if let filePath = filePath {
                let fontFamilies = self.register(filePath)
                for fontFamily in fontFamilies {
                    self.namingMap[fontFamily] = font
                }
                self.cachedFontFamilies.formUnion(fontFamilies)
            }
            callback(key, filePath, error)
        }
    }
    
    public func register(_ path: String) -> Set<String> {
        var fontFamilies = Set<String>()
        
        guard let fontUrl = CFURLCreateWithFileSystemPath(nil, path as CFString, CFURLPathStyle.cfurlposixPathStyle, false) else { return fontFamilies }
        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontUrl) as? [CTFontDescriptor] else {
            return fontFamilies
        }
        CTFontManagerRegisterFontsForURL(fontUrl, .none, nil)
        for descriptor in descriptors {
            let fontRef = CTFontCreateWithFontDescriptor(descriptor, 12, nil)
            guard let cfFontName = CTFontCopyName(fontRef, kCTFontFamilyNameKey) else {
                continue
            }
            let familiName: String = cfFontName as String
            fontFamilies.insert(familiName)
        }
        return fontFamilies
    }
    
    public func registerAll () {
        guard let files = try? self.storage.fileManager.contentsOfDirectory(atPath: self.storage.path) else { return }
        for file in files {
            let fontFamilies = self.register("\(self.storage.path)/\(file)")
            self.cachedFontFamilies.formUnion(fontFamilies)
        }
    }
}
