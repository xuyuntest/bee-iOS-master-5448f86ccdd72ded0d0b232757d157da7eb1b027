//
//  LineDashViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class LinePropertiesViewController: UITableViewController {

    @IBOutlet weak var dashLabel: UILabel?
    
    var line: LineItem? {
        didSet {
            guard let _ = line else { return }
            sync()
        }
    }
    
    static func fromStoryboard () -> LinePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "LinePropertiesView")
    }
    
    func sync () {
        syncDash()
    }
    
    func syncDash () {
        if let line = line {
            dashLabel?.text = line.dash.shortStr
        }
    }

    func syncBack () {
        if let dashLabel = dashLabel, let text = dashLabel.text?.digital, let dash = Float(text) {
            line?.dash = dash
        }
        line?.keepHistory()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.isNumber = true
            inputViewController.title = NSLocalizedString("编辑虚实间隔", comment: "编辑虚实间隔")
            inputViewController.inputTextField?.text = self.dashLabel?.text?.digital
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.dashLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), value.shortStr)
                    return true
                }
                return false
            }
            self.navigationController?.pushViewController(inputViewController, animated: true)
        }
    }
}
