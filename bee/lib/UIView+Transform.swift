//
//  UIView+Transform.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

extension UIView {
    
    @IBInspectable
    open var angel: CGFloat {
        set {
            self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)*angel/180)
        }

        get {
            let transform = self.transform
            let angel = atan2(transform.b, transform.a)
            return angel*180/CGFloat(Double.pi)
        }
    }
}
