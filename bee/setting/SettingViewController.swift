//
//  SettingViewController.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import AlamofireImage

class SettingViewController: UITableViewController {
    
    static func fromStoryboard () -> SettingViewController {
        return UIStoryboard.get("setting")
    }
    
    func cleanup () {
        ImageDownloader.default.imageCache?.removeAllImages()
        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("已清理", comment: "已清理"))
    }

    @objc @IBAction func logout () {
        API.shared.logout()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cleanup()
        } else if indexPath.row == 3 {
            let simpleListViewController = SimpleListViewController.fromStoryboard()
            simpleListViewController.title = NSLocalizedString("多语言", comment: "多语言")
            simpleListViewController.texts = ["中文", "English"]
            simpleListViewController.text = API.isChinese ? "中文" : "English"
            simpleListViewController.delegate = self
            self.navigationController?.pushViewController(simpleListViewController, animated: true)
        } else if indexPath.row == 5 {
            let viewController = PrintersViewController.fromStoryboard()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SettingViewController: SimpleListViewControllerDelegate {
    func didSelectText(simpleListViewController: SimpleListViewController, text: String) {
        if text == "中文"  {
            API.isChinese = true
        } else if text == "English" {
            API.isChinese = false
        }
        SVProgressHUD.showSuccess(withStatus: API.isChinese ? "重启应用才能生效" : "Restart application to take effect")
    }
}
