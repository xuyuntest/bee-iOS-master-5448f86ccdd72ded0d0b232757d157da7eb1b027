//
//  FontPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class FontPropertiesViewController: UITableViewController {

    @IBOutlet weak var fontLabel: UILabel?
    @IBOutlet weak var fontSizeLabel: UILabel?
    @IBOutlet var alignButtons: [UIButton]?
    @IBOutlet weak var boldButton: UIButton?
    @IBOutlet weak var italicButton: UIButton?
    @IBOutlet weak var underlineButton: UIButton?
    @IBOutlet weak var strikeButton: UIButton?
    
    var propertyViewController: PropertyViewController? {
        return self.parent as? PropertyViewController
    }
    
    var textItem: TextItem? {
        didSet {
            guard let _ = textItem else { return }
            sync()
        }
    }
    
    static func fromStoryboard () -> FontPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "FontPropertiesView")
    }
    
    func sync () {
        syncFont ()
        syncFontSize()
        syncAlign()
        syncBold()
        syncItalic()
        syncUnderline()
        syncStrike()
    }
    
    func syncBack () {
        if let fontLabel = fontLabel, let text = fontLabel.text {
            textItem?.font = FontCacher.shared.reversedFontName(text)
        }
        if let fontSizeLabel = fontSizeLabel, let text = fontSizeLabel.text, let value = Float(text) {
            textItem?.fontSize = value
        }
        
        if let alignButton = alignButtons?.first(where: { (button) -> Bool in
            return button.isSelected
        }) {
            textItem?.align = ItemAlign(tag: alignButton.tag) ?? .left
        }
        
        if let boldButton = boldButton {
            textItem?.bold = boldButton.isSelected
        }
        
        if let italicButton = italicButton {
            textItem?.italic = italicButton.isSelected
        }
        
        if let underlineButton = underlineButton {
            textItem?.underline = underlineButton.isSelected
        }
        
        if let strikeButton = strikeButton {
            textItem?.strike = strikeButton.isSelected
        }
        
        textItem?.keepHistory()
    }
    
    func syncFontSize () {
        fontSizeLabel?.text = String(format: "%.1f", textItem?.fontSize ?? 10)
    }
    
    @objc @IBAction func increaseSpeed(sender: UIButton) {
        if let fontSizeLabel = fontSizeLabel, let text = fontSizeLabel.text, let value = Float(text) {
            let fontSize = value + 0.1
            fontSizeLabel.text = String(format: "%.1f", fontSize)
        }
    }
    
    @objc @IBAction func decreaseSpeed(sender: UIButton) {
        if let fontSizeLabel = fontSizeLabel, let text = fontSizeLabel.text, let value = Float(text) {
            let fontSize = value - 0.1
            if fontSize <= 0 {
                return
            }
            fontSizeLabel.text = String(format: "%.1f", fontSize)
        }
    }
    
    func syncAlign () {
        guard let textItem = textItem else { return }
        alignButtons?.forEach({ (button) in
            button.isSelected = ItemAlign(tag: button.tag) == textItem.align
        })
    }
    
    @objc @IBAction func changeAlign(sender: UIButton) {
        alignButtons?.forEach({ (button) in
            button.isSelected = button === sender
        })
    }
    
    func syncFont () {
        let font = textItem?.font ?? ""
        fontLabel?.text = font.isEmpty ? NSLocalizedString("系统默认", comment: "系统默认") : font
    }
    
    func syncBold () {
        boldButton?.isSelected = textItem?.bold ?? false
    }
    
    func syncItalic () {
        italicButton?.isSelected = textItem?.italic ?? false
    }
    
    func syncUnderline () {
        underlineButton?.isSelected = textItem?.underline ?? false
    }
    
    func syncStrike () {
        strikeButton?.isSelected = textItem?.strike ?? false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let familyNames = FontCacher.shared.fontFamilies
            
            let simple = SimpleListViewController.fromStoryboard()
            simple.texts = familyNames.map({ (text) -> String in
                if let font = FontCacher.shared.namingMap[text] {
                    return font.localizedName
                }
                return text
            })
            let font = fontLabel?.text ?? familyNames.first ?? ""
            if let font = FontCacher.shared.namingMap[font] {
                simple.text = font.localizedName
            } else {
                simple.text = font
            }
            propertyViewController?.addViewController(
                simple, confirmBlock: { () -> Bool in
                    self.fontLabel?.text = simple.text
                    return true
            })
        } else if indexPath.row == 3 {
            if let boldButton = boldButton {
                boldButton.isSelected = !boldButton.isSelected
            }
        } else if indexPath.row == 4 {
            if let italicButton = italicButton {
                italicButton.isSelected = !italicButton.isSelected
            }
        } else if indexPath.row == 5 {
            if let underlineButton = underlineButton {
                underlineButton.isSelected = !underlineButton.isSelected
            }
        } else if indexPath.row == 6 {
            if let strikeButton = strikeButton {
                strikeButton.isSelected = !strikeButton.isSelected
            }
        }
    }
}
