//
//  ShapeItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

enum Shape: String, Codable {
    case rect
    case roundedRect
    case ellipse
    case circle
    
    init?(tag: Int) {
        switch tag {
        case 0: self = .rect
        case 1: self = .roundedRect
        case 2: self = .ellipse
        case 3: self = .circle
        default: return nil
        }
    }
    
    func getPath (_ size: CGSize) -> CGMutablePath {
        let path = CGMutablePath()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        switch self {
        case .rect:
            path.addRect(rect)
        case .roundedRect:
            let corner = min(size.width/5, size.height/5)
            path.addRoundedRect(in: rect, cornerWidth: corner, cornerHeight: corner)
        case .ellipse:
            path.addEllipse(in: rect)
        case .circle:
            path.addArc(center: CGPoint(x: size.width*0.5, y: size.height*0.5), radius: min(size.width*0.5, size.height*0.5), startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        }
        return path
    }
}

class ShapeItem: Item {
    var shape: Shape = .rect {
        didSet {
            updateShape()
        }
    }
    var fill: Bool = false {
        didSet {
            updateShape()
        }
    }
    var borderWidth: Float = 1 {
        didSet {
            updateShape()
        }
    }
    
    internal enum ShapeCodingKeys: String, CodingKey {
        case shape
        case fill
        case borderWidth
    }
    
    init() {
        super.init(type: .shape)
        self.width = 5
        self.height = String(format: "%f", self.width/2)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ShapeCodingKeys.self)
        
        if let value = try?container.decodeIfPresent(Shape.self, forKey: .shape), let trueValue = value {
            self.shape = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Bool.self, forKey: .fill), let trueValue = value {
            self.fill = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Float.self, forKey: .borderWidth), let trueValue = value {
            self.borderWidth = trueValue
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: ShapeCodingKeys.self)
        try? contrainer.encode(shape, forKey: .shape)
        try? contrainer.encode(fill, forKey: .fill)
        try? contrainer.encode(borderWidth, forKey: .borderWidth)
    }
    
    override public func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        self.view = UIView()
        self.update()
    }
    
    override internal func update () {
        self.updateShape()
        super.update()
    }
    
    override func updateConstraint () {
        super.updateConstraint()
        if let view = self.view {
            view.layoutIfNeeded()
        }
        self.updateShape()
    }
    
    func updateShape () {
        if let view = self.view {
            let frameSize = self.frameSize
            if frameSize.width <= 0 || frameSize.height <= 0 {
                return
            }
            let backgroundColor = UIColor.black

            let path = self.shape.getPath(frameSize)
            view.addPath(frameSize: frameSize, path: path, strokeColor: backgroundColor, fillColor: self.fill ? backgroundColor : UIColor.clear, lineWidth: CGFloat(self.borderWidth), lineDashPattern: nil)
        }
    }
}
