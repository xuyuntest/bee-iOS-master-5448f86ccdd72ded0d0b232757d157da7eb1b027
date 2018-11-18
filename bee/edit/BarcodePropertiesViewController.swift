//
//  TextPositionPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class BarcodePropertiesViewController: UITableViewController {

    @IBOutlet weak var modeLabel: UILabel?
    @IBOutlet var textPositionButtons: [UIButton]?

    var barcode: BarCodeItem? {
        didSet {
            guard let _ = barcode else { return }
            sync()
        }
    }
    
    var propertyViewController: PropertyViewController? {
        return self.parent as? PropertyViewController
    }
    
    static func fromStoryboard () -> BarcodePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "BarcodePropertiesView")
    }
    
    func sync () {
        syncMode()
        syncTextPosition()
    }
    
    func syncMode () {
        if let barcode = barcode {
            modeLabel?.text = barcode.mode.label
        }
    }
    
    func syncTextPosition () {
        guard let barcode = barcode else { return }
        textPositionButtons?.forEach({ (button) in
            button.isSelected = TextPosition(tag: button.tag) == barcode.textPosition
        })
    }
    
    @objc @IBAction func changeTextPosition(sender: UIButton) {
        textPositionButtons?.forEach({ (button) in
            button.isSelected = button === sender
        })
    }
    
    func syncBack () {
        if let modeLabel = modeLabel, let text = modeLabel.text, let mode = Encoder(label: text) {
            barcode?.mode = mode
        }
        
        if let textPositionButton = textPositionButtons?.first(where: { (button) -> Bool in
            return button.isSelected
        }) {
            barcode?.textPosition = TextPosition(tag: textPositionButton.tag) ?? .noText
        }
        
        barcode?.keepHistory()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let simple = SimpleListViewController.fromStoryboard()
            simple.texts = Encoder.barcodes.filter({ (encoder) -> Bool in
                if encoder == .aztec || encoder == .dataMatrix || encoder == .qrcode  {
                    return false
                }
                return true
            }).map({ (encoder) -> String in
                return encoder.label
            })
            simple.text = modeLabel?.text ?? ""
            propertyViewController?.addViewController(simple, confirmBlock: { () -> Bool in
                self.modeLabel?.text = simple.text
                return true
            })
        }
    }
    
}
