//
//  Tab.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

protocol TabsDelegate: class {
    func onSelectTab(index: Int, tabs:Tabs)
}

class Tabs: UIView {
    
    @IBInspectable
    var spacing: CGFloat = 5
    
    var scrollView: UIScrollView? {
        return self.subviews.first as? UIScrollView
    }
    var current: UIButton? = nil {
        didSet {
            if let old = oldValue {
                old.isSelected = false
            }
            if let current = current {
                current.isSelected = true
                delegate?.onSelectTab(index: current.tag, tabs: self)
            }
        }
    }
    weak var delegate: TabsDelegate? = nil
    
    func setTabs(_ tabs: [String]) {
        assert(tabs.count > 0)
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let view = UIView()
        var trailing: UIView? = nil
        var i = 0
        for tab in tabs {
            let button = UIButton()
            button.tag = i
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.layerRadius = 12
            button.setTitle(tab, for: .normal)
            button.setTitleColor(UIColor("#1a1a1a"), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            button.selectedColor = UIColor.white
            button.addTarget(self, action: #selector(Tabs.selectTab(sender:)), for: UIControlEvents.touchUpInside)
            view.addSubview(button)
            button.snp.makeConstraints { (make) in
                if let trailing = trailing?.snp.trailing {
                    make.leading.equalTo(
                        trailing).offset(self.spacing)
                } else {
                    make.leading.equalTo(view)
                }
                make.top.equalTo(view)
                make.bottom.equalTo(view)
            }
            trailing = button
            
            i += 1
        }
        trailing?.snp.makeConstraints { (make) in
            make.trailing.equalTo(view)
        }
        
        current = view.subviews.first as? UIButton
        
        scrollView.addSubview(view)
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        self.addSubview(scrollView)
        
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(self)
        }
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    @objc func selectTab(sender: UIButton) {
        current = sender
    }
}
