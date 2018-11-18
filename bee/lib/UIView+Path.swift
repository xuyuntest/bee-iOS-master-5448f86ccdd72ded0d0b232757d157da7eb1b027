//
//  UIView+Line.swift
//  bee
//
//  Created by Herb on 2018/8/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

extension UIView {
    
    func clearPath(name: String = "path") {
        self.layer.sublayers?.filter({ (layer) -> Bool in
            return layer.name == name
        }).forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
    }
    
    func addPath (frameSize: CGSize, path: CGPath, strokeColor: UIColor, fillColor: UIColor, lineWidth: CGFloat, lineDashPattern: [NSNumber]? = nil, name: String = "path") {
        self.layer.sublayers?.filter({ (layer) -> Bool in
            return layer.name == name
        }).forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        
        if frameSize.width <= 0 || frameSize.height <= 0 {
            return
        }
        
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        let centerY = frameSize.height / 2
        shapeLayer.name = name
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: centerY)
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        if let lineDashPattern = lineDashPattern {
            shapeLayer.lineDashPattern = lineDashPattern
        }
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
}
