//
//  UIView+Layer.swift
//  bee
//
//  Created by Herb on 2018/8/5.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    var layerBorderColor: UIColor? {
        get {
            guard let color = self.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var layerBorderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var layerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            let radius = newValue
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = radius > 0
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            let radius = newValue
            self.layer.shadowRadius = radius
        }
    }
    
    @IBInspectable
    var shadowOffsetWidth: CGFloat {
        get {
            return self.layer.shadowOffset.width
        }
        set {
            let offset = CGSize(width: newValue, height: self.shadowOffsetHeight)
            self.layer.shadowOffset = offset
        }
    }
    
    @IBInspectable
    var shadowOffsetHeight: CGFloat {
        get {
            return self.layer.shadowOffset.height
        }
        set {
            let offset = CGSize(width: self.shadowOffsetWidth, height: newValue)
            self.layer.shadowOffset = offset
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            guard let color = self.layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
}
