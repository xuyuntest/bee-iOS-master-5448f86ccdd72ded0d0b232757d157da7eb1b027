//
//  Tag.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

enum ItemType: String, Codable, ClassFamily {
    static var discriminator = Discriminator.type

    case text
    case barcode
    case qrcode
    case image
    case line
    case shape
    case table
    case time
    
    init?(tag: Int) {
        switch tag {
        case 0: self = .text
        case 1: self = .barcode
        case 2: self = .qrcode
        case 3: self = .image
        case 4: self = .image
        case 5: self = .line
        case 6: self = .shape
        case 7: self = .table
        case 8: self = .time
        default: return nil
        }
    }
    
    func getType() -> AnyObject.Type {
        switch self {
            case .text: return TextItem.self
            case .barcode: return BarCodeItem.self
            case .qrcode: return QRCodeItem.self
            case .image: return ImageItem.self
            case .line: return LineItem.self
            case .shape: return ShapeItem.self
            case .table: return TableItem.self
            case .time: return TimeItem.self
        }
    }
    
    func getInstance() -> Item {
        switch self {
        case .text: return TextItem()
        case .barcode: return BarCodeItem()
        case .qrcode: return QRCodeItem()
        case .image: return ImageItem()
        case .line: return LineItem()
        case .shape: return ShapeItem()
        case .table: return TableItem()
        case .time: return TimeItem()
        }
    }
}

enum ItemAlign: String, Codable {
    case left
    case right
    case center
    case strech
    
    init?(tag: Int) {
        switch tag {
        case 0: self = .left
        case 1: self = .center
        case 2: self = .right
        case 3: self = .strech        default: return nil
        }
    }
}

let center = "center"

class Item: Codable {
    weak var tag: Tag? = nil {
        didSet {
            tagChanged()
        }
    }

    let type: ItemType
    
    var x: String = center {
        didSet {
            updateConstraint()
        }
    }
    var y: String = center {
        didSet {
            updateConstraint()
        }
    }
    var width: Float = 0 {
        didSet {
            updateConstraint()
        }
    }
    var frameWidth: CGFloat {
        if let tag = self.tag, self.width > 0 {
            return CGFloat(self.width) * tag.scale
        }
        if let view = self.view {
            return view.bounds.size.width
        }
        return 0
    }
    var height: String = "auto" {
        didSet {
            updateConstraint()
        }
    }
    var frameHeight: CGFloat {
        if let tag = self.tag, let height = Float(self.height), height > 0 {
            return CGFloat(height) * tag.scale
        }
        if let view = self.view {
            return view.bounds.size.height
        }
        return 0
    }
    var frameSize: CGSize {
        return CGSize(width: self.frameWidth, height: self.frameHeight)
    }
    var angel: Int = 0 {
        didSet {
            updateAngel()
        }
    }
    var alpha: Float64 = 1 {
        didSet {
            updateAlpha()
        }
    }
    
    var locked: Bool = false
    var printable: Bool = true
    
    var textItem: TextItem? {
        if let item = self as? TextItem {
            return item
        }
        if let item = self as? BarCodeItem {
            return item.text
        }
        if let item = self as? QRCodeItem {
            return item.text
        }
        if let item = self as? TableItem {
            return item.text
        }
        return nil
    }
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case x
        case y
        case width
        case height
        case angel
        case alpha
        case locked
        case printable
    }

    weak var contrainer: UIView? = nil
    var view: UIView? = nil {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }
            if let contrainer = self.contrainer, let view = view {
                contrainer.addSubview(view)
            }
        }
    }
    
    func clone() -> Self {
        let data = try! JSONEncoder().encode(self)
        let decoder = JSONDecoder()
        let copy = try! decoder.decode(Swift.type(of: self), from: data)
        return copy
    }
    
    func keepHistory () {
        if let tag = self.tag {
            tag.keepHistory()
        }
    }
    
    internal func update () {
        updateConstraint()
        updateAngel()
        updateAlpha()
    }
    
    func tagChanged () {
    }
    
    func caculateWidth () -> CGFloat {
        if let view = self.view {
            view.sizeToFit()
            let width = view.bounds.size.width
            return width
        }
        return 0
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
    }
    
    func caculateHeight (_ width: CGFloat) -> CGFloat {
        if let view = self.view {
            let size = view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
            return size.height
        }
        return 0
    }
    
    internal func updateConstraint () {
        if let contrainer = self.contrainer, let view = self.view, let tag = self.tag {
            var width: CGFloat
            if self.width <= 0 {
                width = caculateWidth()
            } else {
                width = CGFloat(self.width) * tag.scale
            }
            
            var height: CGFloat
            if let selfHeight = Float(self.height), selfHeight > 0 {
                height = CGFloat(selfHeight) * tag.scale
            } else {
                height = caculateHeight(width)
            }
            
            view.snp.remakeConstraints({ (make) in
                if x == center {
                    make.centerX.equalTo(contrainer)
                } else {
                    let x = CGFloat(Float(self.x) ?? 0) * tag.scale
                    make.leading.equalTo(contrainer).offset(CGFloat(x))
                }
                if y == center {
                    make.centerY.equalTo(contrainer)
                } else {
                    let y = CGFloat(Float(self.y) ?? 0) * tag.scale
                    make.top.equalTo(contrainer).offset(CGFloat(y))
                }
                if width > 0 {
                    make.width.equalTo(width)
                }
                if height > 0 {
                    make.height.equalTo(height)
                }
            })
        }
    }
    
    private func updateAngel () {
        let angel = CGFloat(Double.pi*Double(self.angel)/180)
        let transform = CGAffineTransform(rotationAngle: angel)
        if let view = self.view {
            view.transform = transform
        }
    }
    
    private func updateAlpha () {
        if let view = self.view {
            view.alpha = CGFloat(self.alpha)
        }
    }
    
    public func bindView(contrainer: UIView) {
        self.contrainer = contrainer
    }
    
    internal init(type: ItemType) {
        self.type = type
    }
}
