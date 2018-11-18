//
//  LocationPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class LocationPropertiesViewController: UITableViewController {
    
    @IBOutlet weak var horizontalCenterButton: UIButton?
    @IBOutlet weak var vericalCenterButton: UIButton?
    
    @IBOutlet weak var widthLabel: UILabel?
    @IBOutlet weak var xLabel: UILabel?
    @IBOutlet weak var yLabel: UILabel?
    
    static func fromStoryboard () -> LocationPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "LocationPropertiesView")
    }
    
    var item: Item? {
        didSet {
            guard let _ = item else { return }
            sync()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.row == 0 {
            if let horizontalCenterButton = self.horizontalCenterButton {
                horizontalCenterButton.isSelected = !horizontalCenterButton.isSelected
            }
        } else if indexPath.row == 1 {
            if let vericalCenterButton = self.vericalCenterButton {
                vericalCenterButton.isSelected = !vericalCenterButton.isSelected
            }
        } else if indexPath.row == 2 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑宽度", comment: "编辑宽度")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = self.widthLabel?.text?.digital
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.widthLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), value.shortStr)
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 3 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑距左距离", comment: "编辑距左距离")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = self.xLabel?.text?.digital
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.xLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), value.shortStr)
                    self.horizontalCenterButton?.isSelected = false
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 4 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑距上距离", comment: "编辑距上距离")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = self.yLabel?.text?.digital
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.yLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), value.shortStr)
                    self.vericalCenterButton?.isSelected = false
                    return true
                }
                return false
            }
            viewController = inputViewController
        }
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func sync () {
        syncHorizontalCenter()
        syncVericalCenter()
        syncX()
        syncY()
        syncWidth()
    }
    
    func syncBack () {
        if let horizontalCenterButton =  self.horizontalCenterButton, horizontalCenterButton.isSelected {
            item?.x = "center"
        } else {
            item?.x = self.xLabel?.text?.digital ?? "0"
        }
        if let vericalCenterButton = vericalCenterButton, vericalCenterButton.isSelected {
            item?.y = "center"
        } else {
            item?.y = self.yLabel?.text?.digital ?? "0"
        }
        
        item?.width = Float(self.widthLabel?.text?.digital ?? "0") ?? 0
        item?.keepHistory()
    }
    
    func syncHorizontalCenter() {
        self.horizontalCenterButton?.isSelected = item?.x == "center"
    }
    
    func syncVericalCenter() {
        self.vericalCenterButton?.isSelected = item?.y == "center"
    }
    
    func syncWidth () {
        self.widthLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (item?.width ?? 0).shortStr)
    }
    
    func syncX () {
        if item?.x == center {
            self.xLabel?.text = NSLocalizedString("居中", comment: "居中")
        } else {
            self.xLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (Float(item?.x ?? "0") ?? 0).shortStr)
        }
    }
    
    func syncY () {
        if item?.y == center {
            self.yLabel?.text = NSLocalizedString("居中", comment: "居中")
        } else {
            self.yLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (Float(item?.y ?? "0") ?? 0).shortStr)
        }
    }
}
