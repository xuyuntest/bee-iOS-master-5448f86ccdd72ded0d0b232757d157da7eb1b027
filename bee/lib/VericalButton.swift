//
//  VericalButton.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

@IBDesignable
class VericalButton: UIButton {

    @IBInspectable
    open var spacing: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private func configureVertically() {
        guard let imageView = self.imageView else { return }
        guard let image = imageView.image else { return }
        let imageSize = image.size
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(imageSize.height + spacing), 0)
        
        guard let titleLabel = self.titleLabel else { return }
        let titleSize = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: titleLabel.frame.size.height))
        self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        configureVertically()
    }
    
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width, height: s.height - self.imageEdgeInsets.top)
    }
}
