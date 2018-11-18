//
//  DashedView.swift
//  bee
//
//  Created by Herb on 2018/8/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class DashedView: UIView {

    private func configureDash() {
        let size = self.bounds.size
        self.addPath(frameSize: size, path: Shape.rect.getPath(size), strokeColor: UIColor("#fabe00"), fillColor: UIColor.clear, lineWidth: 1, lineDashPattern: [2, 2])
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        configureDash()
    }
}
