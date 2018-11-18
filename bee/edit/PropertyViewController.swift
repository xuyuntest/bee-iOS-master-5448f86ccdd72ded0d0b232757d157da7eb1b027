//
//  PropertyViewController.swift
//  bee
//
//  Created by Herb on 2018/8/19.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class PropertyViewController: UIViewController {
    
    @IBOutlet var closeButton: UIButton?
    @IBOutlet var titleLable: UILabel?
    @IBOutlet var contrainerView: UIView?
    @IBOutlet var confirmButton: UIButton?

    var titles = [String]()
    var confirmBlocks = [(() -> Bool)?]()
    
    static func fromStoryboard() -> PropertyViewController {
        return UIStoryboard.get("edit", identifier: "PropertyView")
    }
    
    func addViewController(_ viewController: UIViewController, confirmBlock: (() -> Bool)? = nil, push: Bool = true) {
        self.addChildViewController(viewController)
        self.addView(viewController.title ?? "", view: viewController.view, confirmBlock: confirmBlock, push: push)
    }
    
    func addView(_ title: String, view: UIView, confirmBlock: (() -> Bool)? = nil, push: Bool = true) {
        var needClose = false
        if let contrainerView = self.contrainerView {
            contrainerView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(contrainerView)
            }
            
            if contrainerView.subviews.count > 1 {
                needClose = true
            }
        }
        
        self.titles.append(title)
        self.confirmBlocks.append(confirmBlock)
        self.confirmButton?.isHidden = confirmBlock == nil

        if needClose {
            if let closeButton = self.closeButton {
                closeButton.tag = push ? 0 : 1
                closeButton.setImage(push ? UIImage(named: "nav-back-arrow") : UIImage(named: "icon-close"), for: .normal)
                closeButton.isHidden = false
            }
            if let titleLable = self.titleLable {
                titleLable.text = title
                titleLable.isHidden = false
            }
        } else {
            self.titleLable?.isHidden = true
            self.closeButton?.isHidden = true
        }
    }
    
    func presentView (_ title: String, view: UIView) {
        self.closeAll()
        self.addView(title, view: view, push: false)
    }
    
    @objc @IBAction func handleClose (sender: UIButton) {
        self.popView()
    }
    
    @objc @IBAction func handleConfirm (sender: UIButton) {
        if let confirmBlock = self.confirmBlocks.last, let block = confirmBlock, block() {
            self.popView()
        }
    }
    
    func closeAll() {
        if let contrainerView = self.contrainerView {
            contrainerView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
        }
        for viewController in self.childViewControllers {
            viewController.removeFromParentViewController()
        }
    }
    
    func popView() {
        if let contrainerView = self.contrainerView, let view = contrainerView.subviews.last {
            view.removeFromSuperview()
            for viewController in self.childViewControllers {
                if viewController.view == view {
                    viewController.removeFromParentViewController()
                    break
                }
            }
        }
        
        let _ = self.titles.popLast()
        let _ = self.confirmBlocks.popLast()
        
        let noMore = contrainerView?.subviews.count == 1
        self.closeButton?.isHidden = noMore
        self.titleLable?.isHidden = noMore
        self.confirmButton?.isHidden = noMore
        
        if !noMore {
            if let titleLable = self.titleLable {
                titleLable.text = self.titles.last
            }
        }
    }
}
