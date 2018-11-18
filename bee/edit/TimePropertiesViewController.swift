//
//  TimeViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TimePropertiesViewController: UITableViewController {
    
    @IBOutlet weak var dayFormatterLabel: UILabel?
    @IBOutlet weak var timeFormatterLabel: UILabel?
    @IBOutlet weak var offsetLabel: UILabel?
    
    var time: TimeItem? {
        didSet {
            guard let _ = time else { return }
            sync()
        }
    }
    
    var propertyViewController: PropertyViewController? {
        return self.parent as? PropertyViewController
    }
    
    static func fromStoryboard () -> TimePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "TimePropertiesView")
    }
    
    func sync () {
        syncDayFormatter()
        syncTimeFormatter()
        syncOffset()
    }
    
    func syncDayFormatter () {
        if let time = time {
            dayFormatterLabel?.text = time.dayFormatter
        }
    }
    
    func syncTimeFormatter () {
        if let time = time {
            timeFormatterLabel?.text = time.timeFormatter
        }
    }
    
    func syncOffset() {
        if let time = time {
            offsetLabel?.text = String(format:NSLocalizedString("%d天", comment: "%d天"), time.offset)
        }
    }
    
    @objc @IBAction func increaseOffset(sender: UIButton) {
        if let label = offsetLabel, let text = label.text?.digital, let value = Int(text) {
            let offset = value + 1
            label.text = String(format: NSLocalizedString("%d天", comment: "%d天"), offset)
        }
    }
    
    @objc @IBAction func decreaseOffset(sender: UIButton) {
        if let label = offsetLabel, let text = label.text?.digital, let value = Int(text) {
            let offset = value - 1
            label.text = String(format: NSLocalizedString("%d天", comment: "%d天"), offset)
        }
    }
    
    func syncBack () {
        if let label = self.dayFormatterLabel, let text = label.text {
            time?.dayFormatter = text
        }
        
        if let label = self.timeFormatterLabel, let text = label.text {
            time?.timeFormatter = text
        }
        
        if let label = self.offsetLabel, let text = label.text?.digital, let value = Int(text) {
            time?.offset = value
        }
        time?.keepHistory()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let simple = SimpleListViewController.fromStoryboard()
            simple.title = NSLocalizedString("日期格式", comment: "日期格式")
            simple.texts = [NSLocalizedString("无", comment: "无"),
                NSLocalizedString("yyyy年MM月dd日", comment: "yyyy年MM月dd日"),
                NSLocalizedString("yyyy年MM月", comment: "yyyy年MM月"),
                NSLocalizedString("MM月dd日", comment: "MM月dd日"),
                "yyyy-MM-dd",
                "yyyy-MM",
                "MM-dd",
                "yyyy/MM/dd",
                "yyyy/MM",
                "MM/dd",
                "MM/dd/yyyy",
                "dd/MM/yyyy"]
            simple.text = dayFormatterLabel?.text ?? ""
            propertyViewController?.addViewController(simple, confirmBlock: { () -> Bool in
                self.dayFormatterLabel?.text = simple.text
                return true
            })
        } else if (indexPath.row == 1) {
            let simple = SimpleListViewController.fromStoryboard()
            simple.title = NSLocalizedString("时间格式", comment: "时间格式")
            simple.texts = [NSLocalizedString("无", comment: "无"), "HH:mm:ss", "HH:mm", "mm:ss"]
            simple.text = timeFormatterLabel?.text ?? ""
            propertyViewController?.addViewController(simple, confirmBlock: { () -> Bool in
                self.timeFormatterLabel?.text = simple.text
                return true
            })
        }
    }
}
