//
//  ParaPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class ParaPropertiesViewController: UITableViewController {
    
    @IBOutlet weak var spacingLabel: UILabel?
    @IBOutlet weak var lineSpacingLabel: UILabel?
    @IBOutlet weak var wordWrapButton: UIButton?
    @IBOutlet weak var autoHeightButton: UIButton?
    
    var textItem: TextItem? {
        didSet {
            guard let _ = textItem else { return }
            sync()
        }
    }

    static func fromStoryboard () -> ParaPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "ParaPropertiesView")
    }
    
    func sync () {
        syncSpacing()
        syncLineSpacing()
        syncWordWrap()
        syncAutoHeight()
    }
    
    func syncBack () {
        if let spacingLabel = spacingLabel, let text = spacingLabel.text, let value = Float(text) {
            textItem?.spacing = value
        }
        
        if let lineSpacingLabel = lineSpacingLabel, let text = lineSpacingLabel.text, let value = Float(text.digital) {
            textItem?.lineSpacing = value
        }
        
        if let wordWrapButton = wordWrapButton {
            textItem?.wordWrap = wordWrapButton.isSelected
        }
        
        if let autoHeightButton = autoHeightButton {
            if autoHeightButton.isSelected {
                textItem?.height = "auto"
            } else if textItem?.height == "auto" {
                textItem?.height = "0"
            }
        }
        textItem?.keepHistory()
    }
    
    func syncSpacing () {
        let spacing = textItem?.spacing ?? 0
        let spacingStr = String(format: "%.0f", spacing)
        spacingLabel?.text = spacingStr
    }
    
    @objc @IBAction func increaseSpacing(sender: UIButton) {
        if let spacingLabel = spacingLabel, let text = spacingLabel.text, let value = Float(text) {
            let spacing = value + 1
            spacingLabel.text = String(format: "%.0f", spacing)
        }
    }
    
    @objc @IBAction func decreaseSpacing(sender: UIButton) {
        if let spacingLabel = spacingLabel, let text = spacingLabel.text, let value = Float(text) {
            let spacing = value - 1
            if spacing < 0 {
                return
            }
            spacingLabel.text = String(format: "%.0f", spacing)
        }
    }

    func syncLineSpacing () {
        lineSpacingLabel?.text = String(format: NSLocalizedString("%.1f倍", comment: "%.1f倍"), textItem?.lineSpacing ?? 0)
    }
    
    @objc @IBAction func increaseLineSpacing(sender: UIButton) {
        if let lineSpacingLabel = lineSpacingLabel, let text = lineSpacingLabel.text, let value = Float(text.digital) {
            let lineSpacing = value + 0.1
            lineSpacingLabel.text = String(format: NSLocalizedString("%.1f倍", comment: "%.1f倍"), lineSpacing)
        }
    }
    
    @objc @IBAction func decreaseLineSpacing(sender: UIButton) {
        if let lineSpacingLabel = lineSpacingLabel, let text = lineSpacingLabel.text, let value = Float(text.digital) {
            let lineSpacing = value - 0.1
            if lineSpacing < 0 {
                return
            }
            lineSpacingLabel.text = String(format: NSLocalizedString("%.1f倍", comment: "%.1f倍"), lineSpacing)
        }
    }
    
    func syncWordWrap () {
        wordWrapButton?.isSelected = textItem?.wordWrap ?? false
    }
    
    func syncAutoHeight () {
        autoHeightButton?.isSelected = textItem?.height == "auto"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            if let wordWrapButton = wordWrapButton {
                wordWrapButton.isSelected = !wordWrapButton.isSelected
            }
        } else if indexPath.row == 3 {
            if let autoHeightButton = autoHeightButton {
                autoHeightButton.isSelected = !autoHeightButton.isSelected
            }
        }
    }
}
