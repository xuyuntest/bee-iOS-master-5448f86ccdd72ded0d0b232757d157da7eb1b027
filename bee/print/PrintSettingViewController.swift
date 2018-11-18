//
//  PrintSettingViewController.swift
//  bee
//
//  Created by Herb on 2018/10/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class PrintSettingViewController: UIViewController {
    
    @IBOutlet var settingView: UIView!
    
    var tagWithInfo: TagWithInfo? = nil {
        didSet {
            if let tag = tagWithInfo?.data {
                self.settingViewController?.concentration = Int(tag.printConcentration)
            }
        }
    }
    
    static func print(tag: TagWithInfo?, from: UIViewController) {
        if let _ = PrintersManager.shared.currentPrinter, let tag = tag {
            let printSettingViewController = PrintSettingViewController.fromStoryboard()
            printSettingViewController.tagWithInfo = tag
            from.present(printSettingViewController, animated: true, completion: nil)
        } else {
            let viewController = PrintersViewController.fromStoryboard()
            from.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    var settingViewController: PrintSettingTableViewController? {
        didSet {
            guard let settingViewController = self.settingViewController else { return }
            settingView.addSubview(settingViewController.view)
            settingViewController.view.snp.makeConstraints { (make) in
                make.edges.equalTo(settingView)
            }
            self.addChildViewController(settingViewController)
        }
    }

    static func fromStoryboard () -> PrintSettingViewController {
        return UIStoryboard.get("printer", identifier: "PrintSettingView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingViewController = PrintSettingTableViewController.fromStoryboard()
    }
    
    @IBAction func print(sender: UIButton) {
        if let settingViewController = settingViewController, let printer = PrintersManager.shared.currentPrinter, let tag = tagWithInfo {
            self.dismiss()
            PrintersManager.shared.printTag(tag, concentration: settingViewController.concentration, pagesCount: settingViewController.pagesCount, copiesCount: settingViewController.copiesCount, autoPaging: settingViewController.autoPaging, printer: printer, view: self.view)
        } else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("未连接打印机", comment: "未连接打印机"))
        }
    }
}
