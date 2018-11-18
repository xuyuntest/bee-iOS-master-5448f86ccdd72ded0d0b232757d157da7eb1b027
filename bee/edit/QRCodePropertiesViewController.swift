//
//  QRCodePropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import RSBarcodes_Swift

class QRCodePropertiesViewController: UITableViewController {

    @IBOutlet var spacingButtons: [UIButton]?
    @IBOutlet var correctionLevelButtons: [UIButton]?
    
    var qrcode: QRCodeItem? {
        didSet {
            guard let _ = qrcode else { return }
            sync()
        }
    }
    
    static func fromStoryboard () -> QRCodePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "QRCodePropertiesView")
    }
    
    func sync () {
        syncSpacing()
        syncCorrectionLevel()
    }
    
    func syncSpacing () {
        guard let qrcode = qrcode else { return }
        spacingButtons?.forEach({ (button) in
            button.isSelected = button.tag == qrcode.spacing
        })
    }
    
    @objc @IBAction func changeSpacing(sender: UIButton) {
        spacingButtons?.forEach({ (button) in
            button.isSelected = button === sender
        })
    }
    
    func syncCorrectionLevel () {
        guard let qrcode = qrcode else { return }
        correctionLevelButtons?.forEach({ (button) in
            button.isSelected = InputCorrectionLevel(tag: button.tag) == qrcode.correctionLevel
        })
    }
    
    @objc @IBAction func changeCorrectionLevel(sender: UIButton) {
        correctionLevelButtons?.forEach({ (button) in
            button.isSelected = button === sender
        })
    }
    
    func syncBack () {
        if let correctionLevelButton = correctionLevelButtons?.first(where: { (button) -> Bool in
            return button.isSelected
        }) {
            qrcode?.correctionLevel = InputCorrectionLevel(tag: correctionLevelButton.tag) ?? .Low
        }
        
        if let spacingButton = spacingButtons?.first(where: { (button) -> Bool in
            return button.isSelected
        }) {
            qrcode?.spacing = spacingButton.tag
        }
        qrcode?.keepHistory()
    }

}
