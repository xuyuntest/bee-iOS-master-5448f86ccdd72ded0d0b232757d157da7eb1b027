//
//  ImageItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import SnapKit

class ImageItem: Item {
    var _image: UIImage? = nil {
        didSet {
            if let imageView = imageView {
                imageView.backgroundColor = UIColor.clear
                imageView.image = _image
            }
            self.updateConstraint()
            self.updateGray()
        }
    }
    var image: String = "" {
        didSet {
            updateImage()
        }
    }
    var isLogo: Bool = false
    var tile: Bool = false {
        didSet {
            updateTile()
        }
    }
    var gray: Float = 0 {
        didSet {
            updateGray()
        }
    }
    
    internal enum ImageCodingKeys: String, CodingKey {
        case image
        case isLogo
        case tile
        case gray
    }
    
    var imageView: UIImageView? {
        if let imageView = self.view as? UIImageView {
            return imageView
        }
        if let view = self.view {
            for subView in view.subviews {
                if let imageView = subView as? UIImageView {
                    return imageView
                }
            }
        }
        return nil
    }

    init() {
        super.init(type: .image)
    }
    
    internal override init(type: ItemType) {
        super.init(type: type)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageCodingKeys.self)
        
        if let value = try?container.decodeIfPresent(String.self, forKey: .image), let trueValue = value {
            self.image = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Bool.self, forKey: .isLogo), let trueValue = value {
            self.isLogo = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Bool.self, forKey: .tile), let trueValue = value {
            self.tile = trueValue
        }
        
        if let value = try?container.decodeIfPresent(Float.self, forKey: .gray), let trueValue = value {
            self.gray = trueValue
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: ImageCodingKeys.self)
        try? contrainer.encode(image, forKey: .image)
        try? contrainer.encode(isLogo, forKey: .isLogo)
        try? contrainer.encode(tile, forKey: .tile)
        try? contrainer.encode(gray, forKey: .gray)
    }
    
    override func caculateWidth () -> CGFloat {
        if let imageView = self.imageView, let size = imageView.image?.size {
            var width = size.width
            if let superview = self.view?.superview, width >= superview.bounds.size.width || size.height >= superview.bounds.size.height {
                let scale = min(superview.bounds.size.width/size.width, superview.bounds.size.height/size.height)
                width = size.width * scale * 0.9
            }
            return width
        }
        return 0
    }
    
    override func caculateHeight (_ width: CGFloat) -> CGFloat {
        if let imageView = self.imageView, let size = imageView.image?.size {
            let height = width / size.width * size.height
            return height
        }
        return 0
    }
    
    func generateView () -> UIView {
        let imageView = UIImageView()
        return imageView
    }
    
    override public func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        self.view = self.generateView()
        self.update()
    }
    
    override func update() {
        super.update()
        self.updateTile()
        self.updateImage()
    }
    
    func updateTile () {
        imageView?.contentMode = self.tile ? .scaleToFill : .scaleAspectFit
    }
    
    func updateImage () {
        if !image.isEmpty, let url = image.qiniuURL  {
            imageView?.backgroundColor = UIColor("#f0f0f0")
            if _image != nil {
                return
            }
            imageView?.af_setImage(withURL: url) { (response) in
                self._image = response.value
                if let error = response.error {
                    SVProgressHUD.showError(withStatus: "\(error)")
                }
            }
        }
    }
    
    func updateGray () {
        if gray <= 0 {
            self.imageView?.image = self._image
            return
        }
        guard let cgImage = self._image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        guard let output = CIFilter(name: "CIColorMonochrome", withInputParameters: [
            kCIInputImageKey: ciImage,
            "inputColor": CIColor(red: CGFloat(1 - gray), green: CGFloat(1 - gray), blue: CGFloat(1 - gray), alpha: 1)])?.outputImage else { return }
        let image = UIImage(ciImage: output)
        imageView?.image = image
    }
}
