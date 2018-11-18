//
//  TablePropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/9/20.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class CountCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var countLabel: UILabel?
}

class SizeCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var sizeLabel: UILabel?
}

class TablePropertiesViewController: UITableViewController {
    
    var tableItem: TableItem? = nil {
        didSet {
            self.syncCount()
        }
    }
    var isRow: Bool = true {
        didSet {
            self.title = isRow ? NSLocalizedString("行数", comment: "行数") : NSLocalizedString("列数", comment: "列数")
            self.syncCount()
        }
    }
    
    var pendingCount: Int = -1
    var pendingSizes = [Int: Float]()
    
    static func fromStoryboard () -> TablePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "TablePropertiesView")
    }
    
    func syncCount () {
        if isRow {
            pendingCount = tableItem?.rows ?? 0
        } else {
            pendingCount = tableItem?.columns ?? 0
        }
    }
    
    func syncBack () {
        guard let tableItem = self.tableItem else { return }
        if (pendingCount > 0) {
            if (isRow) {
                tableItem.rows = pendingCount
            } else {
                tableItem.columns = pendingCount
            }
        }
        
        for (position, size) in pendingSizes {
            if (isRow) {
                tableItem.rowHeights[position] = size
            } else {
                tableItem.columnWidths[position] = size
            }
        }
        tableItem.keepHistory()
    }

    @objc @IBAction func increaseCount(sender: UIButton) {
        pendingCount += 1
        let cell = sender.nearestCell as! CountCell
        cell.countLabel?.text = "\(pendingCount)"
        
        tableView.reloadData()
    }
    
    @objc @IBAction func decreaseCount(sender: UIButton) {
        let count = pendingCount - 1
        if count <= 0 {
            return
        }
        pendingCount = count
        let cell = sender.nearestCell as! CountCell
        cell.countLabel?.text = "\(pendingCount)"
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingCount >= 0 {
            return pendingCount + 1
        }
        return (tableItem?.rows ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CountCell", for: indexPath) as! CountCell
            if (isRow) {
                cell.nameLabel?.text = NSLocalizedString("行数", comment: "行数")
                let rows = tableItem?.rows ?? 0
                cell.countLabel?.text = "\(rows)"
            } else {
                cell.nameLabel?.text = NSLocalizedString("列数", comment: "列数")
                let columns = tableItem?.columns ?? 0
                cell.countLabel?.text = "\(columns)"
            }
            if pendingCount >= 0 {
                cell.countLabel?.text = "\(pendingCount)"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SizeCell
            let index = indexPath.row
            let position = indexPath.row - 1
            var size: Float = 0
            if (isRow) {
                cell.nameLabel?.text = NSLocalizedString("第\(index)行高度", comment: "第\(index)行高度")
                if let tableItem = tableItem {
                    size = tableItem.rowHeights[position, default: 0]
                }
            } else {
                cell.nameLabel?.text = String(format: NSLocalizedString("第%d列宽度", comment: "第%d列宽度"), index)
                if let tableItem = tableItem {
                    size = tableItem.columnWidths[position, default: 0]
                }
            }
            size = pendingSizes[position, default: size]
            cell.sizeLabel?.text = String(format: "%@mm", size.shortStr)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableItem = self.tableItem else { return }
        if indexPath.row > 0 {
            let position = indexPath.row - 1
            
            var size: Float = 0
            if (isRow) {
                size = tableItem.rowHeights[position, default: 0]
            } else {
                size = tableItem.columnWidths[position, default: 0]
            }
            size = pendingSizes[position, default: size]

            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = String(format: NSLocalizedString("修改第%d行高度", comment: "修改第%d行高度"), position + 1)
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = "\(size)"
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.pendingSizes[position] = value
                    let cell = tableView.cellForRow(at: indexPath) as! SizeCell
                    cell.sizeLabel?.text = String(format: "%@mm", value.shortStr)
                    return true
                }
                return false
            }
            self.navigationController?.pushViewController(inputViewController, animated: true)
        }
    }
}
