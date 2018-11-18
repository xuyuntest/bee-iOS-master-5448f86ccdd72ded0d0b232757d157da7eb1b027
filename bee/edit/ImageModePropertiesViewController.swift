//
//  ImageModePropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class ImageModePropertiesViewController: UITableViewController {
    
    @IBOutlet var grayButtons: [UIButton]?
    @IBOutlet weak var grayLabel: UILabel?
    @IBOutlet weak var grayProgressBar: UIView?
    
    private var initScale: Float = 0
    
    var image: ImageItem? {
        didSet {
            guard let _ = image else { return }
            sync()
        }
    }
    
    static func fromStoryboard () -> ImageModePropertiesViewController {
        return UIStoryboard.get("edit", identifier: "ImageModePropertiesView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let grayProgressBar = grayProgressBar {
            grayProgressBar.snp.makeConstraints({ (make) in
                make.width.equalTo(
                    grayProgressBar.superview!).multipliedBy(0.2)
            })
        }
    }
    
    func sync () {
        syncGray()
    }
    
    func syncBack () {
        if let text = grayLabel?.text?.digital, let value = Float(text) {
            image?.gray = value/100.0
        }
        image?.keepHistory()
    }
    
    func syncGray () {
        guard let image = self.image else { return }
        syncGray(gray: image.gray)
    }
    
    func syncGray (gray: Float) {
        grayButtons?.forEach({ (button) in
            button.isSelected = false
        })
        if gray <= 0 {
            grayButtons?.first?.isSelected = true
        } else if gray >= 1 {
            grayButtons?[2].isSelected = true
        } else if gray == 0.5 {
            grayButtons?[3].isSelected = true
        } else {
            grayButtons?[1].isSelected = true
        }
        
        grayLabel?.text = String(format: "%.0f%%", gray * 100)
        if let grayProgressBar = grayProgressBar {
            grayProgressBar.snp.remakeConstraints({ (make) in
                make.width.equalTo(
                    grayProgressBar.superview!).multipliedBy(gray)
            })
        }
    }
    
    @objc @IBAction func changeGray (sender: UIButton) {
        grayButtons?.forEach({ (button) in
            button.isSelected = sender === button
        })
        
        var gray: Float = 0
        if sender.tag == 0 {
            gray = 0
        } else if sender.tag == 1 {
            gray = 0.2
        } else if sender.tag == 2 {
            gray = 1
        } else if sender.tag == 3 {
            gray = 0.5
        }
        
        grayLabel?.text = String(format: "%.0f%%", gray * 100)
        if let grayProgressBar = grayProgressBar {
            grayProgressBar.snp.remakeConstraints({ (make) in
                make.width.equalTo(
                    grayProgressBar.superview!).multipliedBy(gray)
            })
        }
    }
    
    @objc @IBAction func panGray(gesture: UIPanGestureRecognizer) {
        guard let grayProgressBar = grayProgressBar else { return }
        guard let superView = grayProgressBar.superview else { return }
        if gesture.state == .began {
            if let text = grayLabel?.text?.digital, let value = Float(text) {
                self.initScale = value/100.0
            }
        }
        let translation = gesture.translation(in: superView)
        let movedScale = translation.x / superView.bounds.size.width
        
        var gray = self.initScale + Float(movedScale)
        if gray < 0 {
            gray = 0
        } else if gray > 1 {
            gray = 1
        }
        syncGray(gray: gray)
    }
}
