//
//  FontPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class PrintSettingTableViewController: UITableViewController {
    
    @IBOutlet weak var printerLabel: UILabel?
    
    @IBOutlet weak var concentrationLabel: UILabel?
    @IBOutlet weak var pageCountLabel: UILabel?
    @IBOutlet weak var copiesCountLabel: UILabel?
    
    @IBOutlet weak var autoPageLabel: UILabel?
    @IBOutlet weak var toggleAutoPageButton: UIButton?
    
    var concentration: Int {
        get {
            if let label = concentrationLabel, let text = label.text, let value = Int(text) {
                return value
            }
            return 0
        }
        
        set {
            concentrationLabel?.text = String(format: "%d", newValue)
        }
    }
    
    var pagesCount: Int {
        if let label = pageCountLabel, let text = label.text, let value = Int(text) {
            return value
        }
        return 1
    }
    
    var copiesCount: Int {
        if let label = copiesCountLabel, let text = label.text, let value = Int(text) {
            return value
        }
        return 1
    }
    
    var autoPaging: Bool {
        return self.toggleAutoPageButton?.isSelected ?? true
    }
    
    static func fromStoryboard () -> PrintSettingTableViewController {
        return UIStoryboard.get("printer", identifier: "PrintSettingTableView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.printerLabel?.text = PrintersManager.shared.currentPrinter?.getName() ?? NSLocalizedString("未连接打印机", comment: "未连接打印机")
    }
    
    @objc @IBAction func increaseConcentration(sender: UIButton) {
        if let label = concentrationLabel, let text = label.text, let value = Int(text) {
            let newValue = value + 1
            if newValue > 16 {
                return
            }
            concentrationLabel?.text = String(format: "%d", newValue)
        }
    }
    
    @objc @IBAction func decreaseConcentration(sender: UIButton) {
        if let label = concentrationLabel, let text = label.text, let value = Int(text) {
            let newValue = value - 1
            if newValue <= 0 {
                return
            }
            concentrationLabel?.text = String(format: "%d", newValue)
        }
    }
    
    @objc @IBAction func increasePageCount(sender: UIButton) {
        if let label = pageCountLabel, let text = label.text, let value = Int(text) {
            let newValue = value + 1
            pageCountLabel?.text = String(format: "%d", newValue)
        }
    }
    
    @objc @IBAction func decreasePageCount(sender: UIButton) {
        if let label = pageCountLabel, let text = label.text, let value = Int(text) {
            let newValue = value - 1
            if newValue <= 0 {
                return
            }
            pageCountLabel?.text = String(format: "%d", newValue)
        }
    }
    
    @objc @IBAction func increaseCopiesCount(sender: UIButton) {
        if let label = copiesCountLabel, let text = label.text, let value = Int(text) {
            let newValue = value + 1
            copiesCountLabel?.text = String(format: "%d", newValue)
        }
    }
    
    @objc @IBAction func decreaseCopiesCount(sender: UIButton) {
        if let label = copiesCountLabel, let text = label.text, let value = Int(text) {
            let newValue = value - 1
            if newValue <= 0 {
                return
            }
            copiesCountLabel?.text = String(format: "%d", newValue)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let viewController = PrintersViewController.fromStoryboard()
            if let from = self.parent?.presentingViewController, let nav = from as? UINavigationController {
                self.dismiss(animated: true) {
                    nav.pushViewController(viewController, animated: true)
                }
            }
        } else if indexPath.row == 4 {
            toggleAutoPageButton?.isSelected = !(toggleAutoPageButton?.isSelected ?? true)
        }
    }
}
