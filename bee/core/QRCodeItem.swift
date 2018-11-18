//
//  QRCodeItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import RSBarcodes_Swift

extension InputCorrectionLevel {
    init?(tag: Int) {
        switch tag {
        case 0: self = .Low
        case 1: self = .Medium
        case 2: self = .Quarter
        case 3: self = .High
        default: return nil
        }
    }
}

extension InputCorrectionLevel: Codable {
}

class QRCodeItem: ImageItem {
    var text = TextItem()
    
    var spacing: Int = 0 {
        didSet {
            updateSpacing()
        }
    }
    var correctionLevel: InputCorrectionLevel = InputCorrectionLevel.Low {
        didSet {
            updateQrcode()
        }
    }
    
    internal enum QRCodeCodingKeys: String, CodingKey {
        case text
        case spacing
        case correctionLevel
    }
    
    override init() {
        super.init(type: .qrcode)
        self.text.text = "1234567890"
        self.text.delegate = self
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QRCodeCodingKeys.self)
        if let value = try?container.decodeIfPresent(TextItem.self, forKey: .text), let trueValue = value {
            self.text = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Int.self, forKey: .spacing), let trueValue = value {
            self.spacing = trueValue
        }
        
        if let value = try?container.decodeIfPresent(InputCorrectionLevel.self, forKey: .correctionLevel), let trueValue = value {
            self.correctionLevel = trueValue
        }
        try super.init(from: decoder)
        self.text.delegate = self
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: QRCodeCodingKeys.self)
        try? contrainer.encode(text, forKey: .text)
        try? contrainer.encode(spacing, forKey: .spacing)
        try? contrainer.encode(correctionLevel, forKey: .correctionLevel)
    }
    
    override internal func update () {
        self.updateSpacing()
        self.updateQrcode()
        super.update()
    }
    
    override func tagChanged() {
        super.tagChanged()
        text.tag = tag
    }
    
    override func caculateHeight (_ width: CGFloat) -> CGFloat {
        return super.caculateHeight(width)  + CGFloat(self.spacing)
    }
    
    override func generateView () -> UIView {
        let view = UIView()
        let imageView = super.generateView()
        view.addSubview(imageView)
        return view
    }
    
    func updateSpacing () {
        if let imageView = self.imageView, let view = imageView.superview {
            imageView.snp.remakeConstraints { (make) in
                make.edges.equalTo(view).offset(self.spacing)
            }
        }
    }
    
    func updateQrcode () {
        if let imageView = self.imageView {
            var text = self.text.text
            if text.isEmpty {
                text = NSLocalizedString("请输入二维码数据", comment: "请输入二维码数据")
            }
            if var image = UIImage.toBarcode(string: text, encoder: .qrcode, inputCorrectionLevel: correctionLevel) {
                if image.size.width < 50 {
                    image = RSAbstractCodeGenerator.resizeImage(image, scale: 50/image.size.width) ?? image
                }
                if let cgImage = image.cgImage, let filter =  CIFilter(name: "CIFalseColor", withInputParameters: ["inputColor0": CIColor(color: UIColor.black), "inputColor1": CIColor(color: UIColor.clear)]) {
                    let ciImage = CIImage(cgImage: cgImage)
                    filter.setValue(ciImage, forKey: kCIInputImageKey)
                    if let output = filter.outputImage {
                        image = UIImage(ciImage: output)
                    }
                }
                imageView.image = image
            }
        }
    }
}

extension QRCodeItem: TextItemProtocol {
    func onTextChanged(_ text: String, textItem: TextItem) {
        updateQrcode()
    }
}
