//
//  FontPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class ItemsAlignPropertiesViewController: UITableViewController {
    
    @IBOutlet weak var vericalCenterButton: UIButton?
    @IBOutlet weak var horizonalCenterButton: UIButton?
    @IBOutlet weak var sameVericalCenterButton: UIButton?
    @IBOutlet weak var sameHorizonalButton: UIButton?
    @IBOutlet var alignButtons: [UIButton]?
    @IBOutlet weak var widthLabel: UILabel?
    @IBOutlet weak var xLabel: UILabel?
    @IBOutlet weak var yLabel: UILabel?

    var propertyViewController: PropertyViewController? {
        return self.parent as? PropertyViewController
    }
    
    var tag: Tag? = nil
    
    static func fromStoryboard () -> ItemsAlignPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "ItemsAlignView")
    }

    
    func syncBack () {
        guard let tag = tag else { return }
        
        if let widthStr = self.widthLabel?.text?.digital, widthStr.count > 0, let width = Float(widthStr) {
            for item in tag.currents {
                item.width = width
            }
        }
        if let xStr = self.xLabel?.text?.digital, xStr.count > 0 {
            for item in tag.currents {
                item.x = xStr
            }
        }
        if let yStr = self.yLabel?.text?.digital, yStr.count > 0 {
            for item in tag.currents {
                item.y = yStr
            }
        }
        
        if let isSelected = self.horizonalCenterButton?.isSelected, isSelected {
            for item in tag.currents {
                item.x = center
            }
        }
        if let isSelected = self.vericalCenterButton?.isSelected, isSelected {
            for item in tag.currents {
                item.y = center
            }
        }
        tag.view?.layoutIfNeeded()
        
        if let alignButtons = alignButtons, let ref = tag.currents.first {
            for button in alignButtons {
                if !button.isSelected {
                    continue
                }
                for (index, item) in tag.currents.enumerated() {
                    if index == 0 {
                        continue
                    }
                    if button.tag == 0 {
                        item.x = ref.x
                    } else if button.tag == 1 {
                        let refX = ref.view?.frame.origin.x ?? 0
                        let x = refX + (ref.frameWidth - item.frameWidth)*0.5
                        item.x = String(Float(x/tag.scale))
                    } else if button.tag == 2 {
                        let refX = ref.view?.frame.origin.x ?? 0
                        let x = refX + (ref.frameWidth - item.frameWidth)
                        item.x = String(Float(x/tag.scale))
                    } else if button.tag == 3 {
                        item.y = ref.y
                    } else if button.tag == 4 {
                        let refY = ref.view?.frame.origin.y ?? 0
                        let y = refY + (ref.frameHeight - item.frameHeight)*0.5
                        item.y = String(Float(y/tag.scale))
                    } else if button.tag == 5 {
                        let refY = ref.view?.frame.origin.y ?? 0
                        let y = refY + (ref.frameHeight - item.frameHeight)
                        item.y = String(Float(y/tag.scale))
                    }
                }
            }
        }
        tag.view?.layoutIfNeeded()
        
        // 整体居中
        let sameHorizonal = self.sameHorizonalButton?.isSelected ?? false
        let sameVericalCenter = self.sameVericalCenterButton?.isSelected ?? false
        if sameHorizonal || sameVericalCenter  {
            var minX = CGFloat.greatestFiniteMagnitude
            var maxX = CGFloat.leastNormalMagnitude
            var minY = CGFloat.greatestFiniteMagnitude
            var maxY = CGFloat.leastNormalMagnitude
            for item in tag.currents {
                let x = item.view?.frame.origin.x ?? 0
                if x < minX {
                    minX = x
                }
                
                let xOver = x + item.frameWidth
                if xOver > maxX {
                    maxX = xOver
                }
                
                let y = item.view?.frame.origin.y ?? 0
                if y < minY {
                    minY = y
                }
                
                let yOver = y + item.frameHeight
                if yOver > maxY {
                    maxY = yOver
                }
            }
            
            let width = maxX - minX
            let offsetX = ((tag.view?.frame.size.width ?? 0) - width) * 0.5 - minX
            let height = maxY - minY
            let offsetY = ((tag.view?.frame.size.height ?? 0) - height) * 0.5 - minY
            
            for item in tag.currents {
                if offsetX != 0, sameHorizonal {
                    let oldX = item.view?.frame.origin.x ?? 0
                    let x = oldX + offsetX
                    item.x = String(Float(x/tag.scale))
                }
                if offsetY != 0, sameVericalCenter {
                    let oldY = item.view?.frame.origin.y ?? 0
                    let y = oldY + offsetY
                    item.y = String(Float(y/tag.scale))
                }
            }
        }
        
        tag.keepHistory()
    }
    
    @objc @IBAction func changeAlign(sender: UIButton) {
        alignButtons?.forEach({ (button) in
            if sender.tag < 3 && button.tag < 3 {
                button.isSelected = false
            } else if sender.tag >= 3 && button.tag >= 3 {
                button.isSelected = false
            }
        })
        sender.isSelected = !sender.isSelected
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.row == 0 {
            if let horizonalCenterButton = horizonalCenterButton {
                horizonalCenterButton.isSelected = !horizonalCenterButton.isSelected
            }
        } else if indexPath.row == 1 {
            if let vericalCenterButton = vericalCenterButton {
                vericalCenterButton.isSelected = !vericalCenterButton.isSelected
            }
        } else if indexPath.row == 2 {
            if let sameHorizonalButton = sameHorizonalButton {
                sameHorizonalButton.isSelected = !sameHorizonalButton.isSelected
            }
        } else if indexPath.row == 3 {
            if let sameVericalCenterButton = sameVericalCenterButton {
                sameVericalCenterButton.isSelected = !sameVericalCenterButton.isSelected
            }
        } else if indexPath.row == 5 {
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
        } else if indexPath.row == 6 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑距左距离", comment: "编辑距左距离")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = self.xLabel?.text?.digital
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.xLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), value.shortStr)
                    self.horizonalCenterButton?.isSelected = false
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 7 {
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
}
