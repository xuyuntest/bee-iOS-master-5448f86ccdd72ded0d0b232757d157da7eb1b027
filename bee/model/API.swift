//
//  API.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import os.log
import Foundation
import Alamofire

enum SimpleError: Error {
    case string(String)
}

class API {
    
    static let shared = API()
    
    let baseURL = URL(string: "https://backend.beeprt.com/api/")!
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    public static var isChinese: Bool {
        set {
            if newValue {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            }
        }
        
        get {
            if let langs = UserDefaults.standard.array(forKey: "AppleLanguages"), langs.count > 0, let lang = langs[0] as? String, lang == "en" {
                return false
            }
            if let lang = NSLocale.current.languageCode, let range = lang.range(of: "zh"), range.lowerBound == lang.startIndex {
                return true
            }
            return false
        }
    }
    
    public var token: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
    }
    
    public var newTagsCount: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "new_tags_count")
        }
        get {
            return UserDefaults.standard.integer(forKey: "new_tags_count")
        }
    }
    
    public var recentTags: [TagWithInfo] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "recent_tags") else { return [] }
            let tags = (try? JSONDecoder().decode([TagWithInfo].self, from: data)) ?? []
            return tags
        }
        set {
            let limit = 20
            let value: [TagWithInfo]
            if newValue.count > limit {
                value = Array(newValue[0..<limit])
            } else {
                value = newValue
            }
            if let data = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(data, forKey: "recent_tags")
            }
        }
    }
    
    private init () {}
    
    public func addRecentTag(_ tag: TagWithInfo) {
        for (index, aTag) in recentTags.enumerated() {
            if aTag.template_id == tag.template_id {
                recentTags.remove(at: index)
                break
            }
        }
        recentTags.insert(tag, at: 0)
    }
    
    public func sendCode (_ phone: String, callback: @escaping ((Response?, Error?) -> Void)) {
        self.quickAPI("user/sms", method: .post, parameters: ["phone": phone], callback: callback)
    }
    
    public func login (_ user: User, callback: @escaping ((User?, Error?) -> Void)) {
        self.quickAPI("user/signin", method: .post, parameters: user) { (value: User?, error: Error?) in
            if let user = value, let token = user.token {
                self.token = token
            }
            callback(value, error)
        }
    }
    
    public func login(_ phone: String, code: String, callback: @escaping ((User?, Error?) -> Swift.Void)) {
        self.quickAPI("user/login", method: .post, parameters: ["phone": phone, "code": code]) { (value: User?, error: Error?) in
            if let user = value, let token = user.token {
                self.token = token
            }
            callback(value, error)
        }
    }
    
    public func logout () {
        self.token = ""
    }
    
    public func loginByWechat(code: String, callback: @escaping ((User?, Error?) -> Swift.Void)) {
        Alamofire.request("https://api.weixin.qq.com/sns/oauth2/access_token", parameters: [
            "appid": "wx24c48fd968439445",
            "secret": "edac02c9da94b6ec79677197f3c12e4b",
            "grant_type": "authorization_code",
            "code": code]).validate(statusCode: 200..<300).responseJSON { (response) in
                if let resp = response.value as? [String: Any], let accessToken = resp["access_token"], let openid = resp["openid"] as? String, openid.count > 0 {
                    let lang = "zh_CN"
                    Alamofire.request("https://api.weixin.qq.com/sns/userinfo", parameters: ["access_token": accessToken, "openid": openid, "lang": lang]).responseJSON(completionHandler: { (response) in
                        if let resp = response.value as? [String: Any], let nickname = resp["nickname"] as? String {
                            let user = User()
                            user.avatar = resp["headimgurl"] as? String ?? ""
                            user.gender = Gender(rawValue: resp["sex"] as? Int ?? 1) ?? Gender.male
                            user.country = resp["country"] as? String ?? ""
                            user.province = resp["province"] as? String ?? ""
                            user.city = resp["city"] as? String ?? ""
                            user.openid = openid
                            user.nickname = nickname
                            self.login(user, callback: callback)
                        } else {
                            callback(nil, nil)
                        }
                    })
                } else {
                    callback(nil, nil)
                }
        }
    }
    
    public func getLogoCategories (_ callback: @escaping (([TagCategory]?, Error?) -> Void)) {
        self.quickAPI("logo/cates", callback: callback)
    }
    
    public func getLogos(_ categoryId: String, callback: @escaping (([Logo]?, Error?) -> Void)) {
        self.quickAPI("logo/list", parameters: ["cate_id": categoryId], callback: callback)
    }
    
    public func getFonts(_ callback: @escaping (([Font]?, Error?) -> Void)) {
        self.quickAPI("material/font", callback: callback)
    }
    
    public func getTagCategories (_ callback: @escaping (([TagCategory]?, Error?) -> Void)) {
        self.quickAPI("template/cates", callback: callback)
    }
    
    public func getMyTags(callback: @escaping (([TagWithInfo]?, Error?) -> Void)) {
        self.quickAPI("template/mine", callback: callback)
    }
    
    public func getTagInCategory(_ id: String, callback: @escaping ((TagWithInfos?, Error?) -> Void)) {
        self.quickAPI("template/list", parameters: ["cate_id": id],  callback: callback)
    }

    public func getTag(tag: String, callback: @escaping ((TagWithInfo?, Error?) -> Void)) {
        self.quickAPI("template/tag", parameters: ["tag": tag], callback: callback)
    }
    
    public func getTag(_ id: String, callback: @escaping ((TagWithInfo?, Error?) -> Void)) {
        self.quickAPI("template", parameters: ["template_id": id], callback: callback)
    }
    
    public func updateTag(_ tag: TagWithInfo, callback: @escaping ((TagWithInfo?, Error?) -> Void)) {
        if let width = tag.data?.width {
            tag.width = width
        }
        if let height = tag.data?.height {
            tag.height = height
        }
        if let templateId = tag.template_id, !templateId.isEmpty {
            self.quickAPI("template/update?template_id=\(templateId)", method: .put, parameters:tag) { (value: TagWithInfo?, error: Error?) in
                if let tagWithInfo = value {
                    self.addRecentTag(tagWithInfo)
                }
                callback(value, error)
            }
        } else {
            self.quickAPI("template/create", method: .post, parameters:tag) { (value: TagWithInfo?, error: Error?) in
                if let tagWithInfo = value {
                    self.addRecentTag(tagWithInfo)
                }
                callback(value, error)
            }
        }
    }
    
    public func deleteTag(_ id: String, callback: @escaping ((Response?, Error?) -> Void)) {
        self.quickAPI("template/delete?template_id=" + id, method: .delete, parameters:["template_id": id]) { (response: Response?, error: Error?) in
            if error == nil {
                self.recentTags = self.recentTags.filter({ (tag) -> Bool in
                    return tag.template_id != id
                })
            }
            callback(response, error)
        }
    }
    
    public func toggleTagPublic(_ id: String, categoryId: String, isPublic: Bool, callback: @escaping ((Tag?, Error?) -> Void)) {
        self.quickAPI("template/list", method: .put, parameters:["cate_id": categoryId, "template_id": id, "public": isPublic],  callback: callback)
    }
    
    public func forkTag(_ id: String, callback: @escaping ((Tag?, Error?) -> Void)) {
        self.quickAPI("template/fork", parameters:["template_id": id], callback: callback)
    }
    
    public func sendFeedback(_ feedback: String, callback: @escaping ((Response?, Error?) -> Void)) {
        self.quickAPI("feedback", method: .post, parameters:["content": feedback], callback: callback)
    }
    
    public func upload(_ data: Any, callback: @escaping ((String?, Error?) -> Void)) {
        self.quickAPI("image/token") { (response: QiniuToken?, error: Error?) in
            if let response = response {
                let fileData: Data
                if let image = data as? UIImage {
                    fileData = UIImagePNGRepresentation(image)!
                } else {
                    fileData = data as! Data
                }
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(
                            fileData, withName: "file")
                        multipartFormData.append(
                            response.token.data(using: .utf8)!, withName: "token")
                },
                    to: "https://up.qiniup.com",
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                if let error = response.error {
                                    callback(nil, error)
                                    return
                                }
                                let json = response.result.value as! [String: Any]
                                if let key = json["key"] as? String {
                                    callback(key, nil)
                                } else {
                                    callback(nil, SimpleError.string(NSLocalizedString("上传失败", comment: "上传失败")))
                                }
                            }
                        case .failure(let encodingError):
                            callback(nil, encodingError)
                        }
                })
                return
            }
            callback(nil, error)
        }
    }
    
    private func quickAPI<T>(_ url: String, method: HTTPMethod = .get, parameters: Any? = nil, callback: @escaping ((T?, Error?) -> Void)) where T : Codable {
        self.request(url, method: method, parameters: parameters).responseData { (response) in
            do {
                let value = try self.process(response: response, type: T.self)
                callback(value, nil)
            } catch {
                callback(nil, error)
            }
        }
    }
    
    open func request(
        _ path: String,
        method: HTTPMethod = .post,
        parameters: Any? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders = HTTPHeaders()) -> DataRequest {
        let url = URL(string: path, relativeTo: baseURL)!
        
        var processedHeaders = headers
        processedHeaders["token"] = self.token

        var processedParameters: Parameters
        if let parameters = parameters as? Parameters {
            processedParameters = parameters
        } else if let encodable = parameters as? Request {
            processedParameters = encodable.postDictionary
        } else if let encodable = parameters as? Encodable {
            processedParameters = encodable.dictionary
        } else {
            processedParameters = [:]
        }
        return Alamofire.request(url, method: method, parameters: processedParameters, encoding: method == .get ? URLEncoding.default : encoding, headers: processedHeaders)
    }
    
    open func process<T>(response: DataResponse<Data>, type: T.Type) throws -> T? where T : Decodable {
        if let error = response.error {
            throw error
        }
        switch response.result {
        case .failure(let error):
            throw error
        case .success(_):
            if let data = response.data {
                #if DEBUG
                let str = String(bytes: data, encoding: .utf8) ?? ""
                print("返回: \(str)")
                #endif
                let decoder = JSONDecoder()
                if let serverResponse = try? decoder.decode(Response.self, from: data), let status = serverResponse.status, status >= 400 {
                    if status == 401 {
                        self.logout()
                        NotificationCenter.default.post(name: NSNotification.Name("Unauthorized"), object: nil)
                    }
                    let msg = serverResponse.message ?? NSLocalizedString("请稍后重试", comment: "请稍后重试")
                    throw SimpleError.string("\(msg)")
                }
                do {
                    let value = try decoder.decode(type, from: data)
                    return value
                } catch {
                    let str = String(bytes: data, encoding: .utf8) ?? ""
                    if str.isEmpty || str == "true" {
                       return nil
                    } else {
                        print("编码错误: \(error), 返回: \(str)")
                        throw error
                    }
                }
            }
            throw SimpleError.string(NSLocalizedString("请稍后重试", comment: "请稍后重试"))
        }
    }
}
