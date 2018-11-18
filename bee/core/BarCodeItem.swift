//
//  OneDimensionCodeItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import RSBarcodes_Swift

enum TextPosition: String, Codable {
    case noText
    case above
    case below

    init?(tag: Int) {
        switch tag {
        case 0: self = .noText
        case 1: self = .above
        case 2: self = .below
        default: return nil
        }
    }
}

class BarCodeItem: ImageItem {
    var text = TextItem()
    
    var mode: Encoder = Encoder.code128 {
        didSet {
            updateBarcode()
        }
    }
    var textPosition: TextPosition = .below {
        didSet {
            updateTextPosition()
        }
    }
    
    internal enum BarCodeCodingKeys: String, CodingKey {
        case text
        case mode
        case textPosition
    }
    
    var label: UILabel? {
        if let view = self.view {
            for subView in view.subviews {
                if let label = subView as? UILabel {
                    return label
                }
            }
        }
        return nil
    }
    
    override init() {
        super.init(type: .barcode)
        self.tile = true
        self.text.text = "1234567890"
        self.text.wordWrap = false
        self.text.delegate = self
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BarCodeCodingKeys.self)
        if let value = try?container.decodeIfPresent(TextItem.self, forKey: .text), let trueValue = value {
            self.text = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Encoder.self, forKey: .mode), let trueValue = value {
            self.mode = trueValue
        }
        
        if let value = try?container.decodeIfPresent(TextPosition.self, forKey: .textPosition), let trueValue = value {
            self.textPosition = trueValue
        }
        
        try super.init(from: decoder)
        self.text.delegate = self
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: BarCodeCodingKeys.self)
        try? contrainer.encode(text, forKey: .text)
        try? contrainer.encode(mode, forKey: .mode)
        try? contrainer.encode(textPosition, forKey: .textPosition)
    }
    
    override func tagChanged() {
        super.tagChanged()
        text.tag = tag
    }
    
    override internal func update () {
        text.update()
        self.updateBarcode()
        self.updateTextPosition()
        super.update()
    }
    
    override func generateView () -> UIView {
        let view = UIView()
        let imageView = super.generateView()
        view.addSubview(imageView)
        text.bindView(contrainer: view)
        return view
    }
    
    override func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        self.updateTextPosition()
    }
    
    func updateTextPosition () {
        if let view = view, let label = text.label, let imageView = imageView {
            imageView.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentHuggingPriority(.required, for: .vertical)
            imageView.snp.remakeConstraints { (make) in
                make.leading.equalTo(view)
                make.trailing.equalTo(view)
                
                if textPosition == .below {
                    make.top.equalTo(view)
                    make.bottom.equalTo(label.snp.top)
                } else if textPosition == .above {
                    make.top.equalTo(label.snp.bottom)
                    make.bottom.equalTo(view)
                } else {
                    make.top.equalTo(view)
                    make.bottom.equalTo(view)
                }
            }
            
            label.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                
                if textPosition == .below {
                    make.bottom.equalTo(view)
                } else if textPosition == .above {
                    make.top.equalTo(label)
                } else {
                    make.centerY.equalTo(view)
                    make.height.equalTo(0)
                }
            }
        }
    }
    
    func updateBarcode () {
        if let imageView = self.imageView {
            var txt = text.text
            if txt.count == 0 {
                txt = mode.rawValue
            }
            imageView.image = UIImage.toBarcode(string: txt, encoder: mode, inputCorrectionLevel: InputCorrectionLevel.High)
        }
    }
    
    override func caculateWidth() -> CGFloat {
        let width = super.caculateWidth()
        if textPosition != .noText {
            let textWidth = text.caculateWidth()
            return max(width, textWidth)
        }
        return width
    }
    
    override func caculateHeight (_ width: CGFloat) -> CGFloat {
        return super.caculateHeight(width)  + (textPosition != .noText ? text.caculateHeight(width) : 0)
    }
}

extension BarCodeItem: TextItemProtocol {
    func onTextChanged(_ text: String, textItem: TextItem) {
        updateBarcode()
    }
}

