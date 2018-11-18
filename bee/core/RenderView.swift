//
//  RenderView.swift
//  bee
//
//  Created by Herb on 2018/9/6.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class RenderView: UIView {
    
    var scaleWhenRender: Float = 8
    var scale: CGFloat = 1
    var showBackground: Bool = true
    
    private var inputTag: Tag?
    private var callback: ((UIImage?, Error?) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup () {
        self.backgroundColor = UIColor.white
        self.isHidden = true
    }
    
    func render(_ tag: Tag, view: UIView, callback: @escaping ((UIImage?, Error?) -> Void)) {
        self.removeFromSuperview()
        view.insertSubview(self, at: 0)
        let w = CGFloat(tag.width*self.scaleWhenRender)
        let h = CGFloat(tag.height*self.scaleWhenRender)
        self.snp.makeConstraints { (make) in
            make.width.equalTo(w)
            make.height.equalTo(h)
            make.center.equalTo(view)
        }
        self.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        let tagView = UIView()
        self.addSubview(tagView)
        tagView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(
                tag.printVericalOffset*self.scaleWhenRender)
            make.left.equalTo(self).offset(
                tag.printHorizontalOffset*self.scaleWhenRender)
            make.height.equalTo(h)
            make.width.equalTo(w)
        }
        self.clipsToBounds = true
        self.layoutIfNeeded()
        
        #if DEBUG
        let imageView = UIImageView()
        imageView.tag = 1024
        view.insertSubview(imageView, at: 0)
        imageView.snp.remakeConstraints { (make) in
            make.edges.equalTo(view)
        }
        #endif
        let inputTag = tag.clone()
        inputTag.bindView(view: tagView, onlyPrintable: true, showBackground: showBackground)
        self.inputTag = inputTag
        self.callback = callback
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layouted()
    }
    
    func layouted () {
        guard let inputTag = inputTag else { return }
        guard let callback = callback else { return }
        
        if showBackground, !inputTag.background.isEmpty {
            if inputTag.backgroundView?.image === nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.layouted()
                }
                return
            }
        }
        for item in inputTag.items {
            if let imageItem = item as? ImageItem, !imageItem.image.isEmpty {
                if imageItem.imageView?.image === nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.layouted()
                    }
                    return
                }
            }
        }
        
        self.callback = nil
        
        self.isHidden = false
        UIGraphicsBeginImageContextWithOptions(
            self.frame.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        self.layer.render(in: context)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if !showBackground, inputTag.angel > 0 {
            // rotate
            let angel = CGFloat(Double.pi*Double(inputTag.angel)/180)
            image = image?.image(withRotation: angel)
        }
        
        callback(image, nil)
        
        #if DEBUG
        if let imageView = self.superview?.viewWithTag(1024) as? UIImageView {
            imageView.image = image
        }
        #else
        self.removeFromSuperview()
        #endif
    }
}
