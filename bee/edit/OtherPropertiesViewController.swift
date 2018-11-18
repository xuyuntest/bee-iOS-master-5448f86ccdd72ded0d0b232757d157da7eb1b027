//
//  OtherPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class OtherPropertiesViewController: UITableViewController {
    
    @IBOutlet weak var lockButton: UIButton?
    @IBOutlet weak var printableButton: UIButton?
    
    var item: Item? {
        didSet {
            if let _ = item {
                sync()
            }
        }
    }
    
    static func fromStoryboard () -> OtherPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "OtherPropertiesView")
    }
    
    func sync () {
        syncLock()
        syncPrintable()
    }
    
    func syncBack () {
        if let lockButton = lockButton {
            item?.locked = lockButton.isSelected
        }
        if let printableButton = printableButton {
            item?.printable = printableButton.isSelected
        }
    }
    
    func syncLock () {
        lockButton?.isSelected = item?.locked ?? false
    }
    
    func syncPrintable () {
        printableButton?.isSelected = item?.printable ?? true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let lockButton = lockButton {
                lockButton.isSelected = !lockButton.isSelected
            }
        } else if indexPath.row == 1 {
            if let printableButton = printableButton {
                printableButton.isSelected = !printableButton.isSelected
            }
        }
    }
}
