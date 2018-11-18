//
//  UIView+NearestCell.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

extension UIView {
    
    var nearestCell: UITableViewCell? {
        var superview: UIView? = self
        while true {
            superview = superview?.superview
            if superview == nil {
                return nil
            }
            if let cell = superview as? UITableViewCell {
                return cell
            }
        }
    }
}
