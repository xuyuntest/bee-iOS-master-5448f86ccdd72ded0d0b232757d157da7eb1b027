//
//  BoderedButton.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class BoderedButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            guard let selectedBorderColor = selectedBorderColor else { return }
            if isSelected {
                self.oldLayerBorderColor = self.layerBorderColor
                self.layerBorderColor = selectedBorderColor
            } else if let oldLayerBorderColor = oldLayerBorderColor {
                self.layerBorderColor = oldLayerBorderColor
            }
        }
    }

    @IBInspectable
    var selectedBorderColor: UIColor?
    var oldLayerBorderColor: UIColor?

}
