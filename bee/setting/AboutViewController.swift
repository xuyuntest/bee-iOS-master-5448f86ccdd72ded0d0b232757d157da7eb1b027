//
//  AboutViewController.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import Alamofire

class AboutViewController: UIViewController {

    @IBOutlet var currentVersionLabel: UILabel!
    @IBOutlet var newestVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"], let versionStr = version as? String {
            currentVersionLabel.text = String(format: NSLocalizedString("当前版本：%@", comment: "当前版本：%@"), versionStr)
        }
        let itunesAPIUrl = "http://itunes.apple.com/lookup?bundleId=0"
        Alamofire.request(itunesAPIUrl).responseJSON { (response) in
            if let value = response.value, let obj = value as? Dictionary<String, Any>, let results = obj["results"] as? Array<Dictionary<String, Any>>, let result = results.first, let version = result["version"] as? String {
                self.newestVersionLabel.text = String(format: NSLocalizedString("最新版本: %@", comment: "最新版本: %@"), version)
            }
        }
    }
    
    @objc @IBAction func checkUpgrade () {
        let url = URL(string: "itms://itunes.apple.com/us/app/bee/id")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
