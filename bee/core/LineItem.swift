//
//  LineItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class LineItem: Item {
    var dash: Float = 0 {
        didSet {
            updateLine()
        }
    }
    
    internal enum LineCodingKeys: String, CodingKey {
        case dash
    }
    
    var lineView: UIView? {
        return self.view?.subviews.first
    }
    
    init() {
        super.init(type: .line)
        self.width = 5
        self.height = String(format: "%f", 1.0/8)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LineCodingKeys.self)
        if let value = try?container.decodeIfPresent(Float.self, forKey: .dash), let trueValue = value {
            self.dash = trueValue
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: LineCodingKeys.self)
        try? contrainer.encode(dash, forKey: .dash)
    }
    
    override public func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        let lineView = UIView()
        let view = UIView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.centerY.equalTo(view)
            make.height.equalTo(0)
        }
        self.view = view
        self.update()
    }
    
    override internal func update () {
        self.updateLine()
        super.update()
    }
    
    override func updateConstraint () {
        super.updateConstraint()
        if let tag = tag {
            lineView?.snp.updateConstraints({ (make) in
                var height = (Float(self.height) ?? 1/8.0) * Float(tag.scale)
                if height < 1 {
                    height = 1
                }
                make.height.equalTo(height)
            })
        }
        if let view = self.view {
            view.layoutIfNeeded()
        }
        self.updateLine()
    }
    
    func updateLine () {
        if let view = self.lineView {
            let backgroundColor = UIColor.black
            if self.dash > 0 {
                let frameSize = self.frameSize
                if frameSize.width <= 0 || frameSize.height <= 0 {
                    return
                }
                let centerY = frameSize.height / 2
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: centerY))
                path.addLine(to: CGPoint(x: frameSize.width, y:centerY))
                
                view.backgroundColor = UIColor.clear
                view.addPath(frameSize: frameSize, path: path, strokeColor: backgroundColor, fillColor: UIColor.clear, lineWidth: 1, lineDashPattern: [self.dash, self.dash] as [NSNumber])
            } else {
                view.clearPath()
                view.backgroundColor = backgroundColor
            }
        }
    }
}
