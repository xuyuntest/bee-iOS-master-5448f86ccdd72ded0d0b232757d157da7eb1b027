//
//  UIImage+Rotate.swift
//  bee
//
//  Created by Herb on 2018/10/10.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

extension UIImage {

    func image(withRotation radians: CGFloat) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        guard let bitmap = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
            return self
        }
        
        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        bitmap.rotate(by: radians);
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
