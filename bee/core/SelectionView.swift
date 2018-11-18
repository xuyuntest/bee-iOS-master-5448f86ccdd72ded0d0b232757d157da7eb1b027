//
//  WrapperView.swift
//  bee
//
//  Created by Herb on 2018/7/31.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

protocol SelectionViewDelegate: class {
    func handleClose(_ selectionView: SelectionView)
    func handleRotate(_ selectionView: SelectionView)
    func handleZoomExist(_ selectionView: SelectionView, event: UIEvent)
    func handleZoom(_ selectionView: SelectionView, event: UIEvent)
    func handlePan(_ selectionView: SelectionView, sender: UIPanGestureRecognizer)
}

class SelectionView: UIView {
    
    let contentView = UIView()
    weak var item: Item?
    weak var delegate: SelectionViewDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func bind(_ item: Item, hPadding: CGFloat = 10, vPadding: CGFloat = 6) {
        self.item = item
        if let view = item.view {
            assert(view.superview == self.superview)
            contentView.snp.remakeConstraints { (make) in
                make.leading.equalTo(view).offset(-hPadding)
                make.trailing.equalTo(view).offset(hPadding)
                make.top.equalTo(view).offset(-vPadding)
                make.bottom.equalTo(view).offset(vPadding)
                
                make.leading.equalTo(self).offset(10)
                make.trailing.equalTo(self).offset(-10)
                make.top.equalTo(self).offset(10)
                make.bottom.equalTo(self).offset(-10)
            }
            self.transform = view.transform
        }
    }
    
    @objc func handleClose() {
        delegate?.handleClose(self)
    }
    
    @objc func handleRotate() {
        delegate?.handleRotate(self)
    }
    
    @objc func handleZoomExist(sender: UIButton, event: UIEvent) {
        delegate?.handleZoomExist(self, event: event)
    }
    
    @objc func handleZoom(sender: UIButton, event: UIEvent) {
        delegate?.handleZoom(self, event: event)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        delegate?.handlePan(self, sender: sender)
    }
    
    func setup () {
        self.translatesAutoresizingMaskIntoConstraints = false

        contentView.layer.borderColor = UIColor("#fabe00").cgColor
        contentView.layer.borderWidth = 2
        self.addSubview(contentView)
        
        let close = UIButton()
        close.setImage(UIImage(named: "close"), for: .normal)
        close.addTarget(self, action: #selector(SelectionView.handleClose), for: .touchUpInside)
        self.addSubview(close)
        close.snp.makeConstraints { (make) in
            make.leading.equalTo(self)
            make.top.equalTo(self)
        }
        
        let rotate = UIButton()
        rotate.setImage(UIImage(named: "rotate"), for: .normal)
        rotate.addTarget(self, action: #selector(SelectionView.handleRotate), for: .touchUpInside)
        self.addSubview(rotate)
        rotate.snp.makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
        }
        
        let zoom = UIButton()
        zoom.setImage(UIImage(named: "zoom"), for: .normal)
        zoom.addTarget(self, action: #selector(SelectionView.handleZoom(sender:event:)), for: UIControlEvents.touchDragInside)
        zoom.addTarget(self, action: #selector(SelectionView.handleZoomExist(sender:event:)), for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside])
        self.addSubview(zoom)
        zoom.snp.makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.bottom.equalTo(self)
        }
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(SelectionView.handlePan(sender:)))
        contentView.addGestureRecognizer(recognizer)
    }
}
