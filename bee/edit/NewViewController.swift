//
//  ViewController.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {
    
    @IBOutlet weak var titleButton: UIButton?
    @IBOutlet weak var contrainer: UIView?
    @IBOutlet weak var propertyView: UIView?
    
    var tagPropertiesViewController: TagPropertiesViewController? {
        didSet {
            guard let propertyView = self.propertyView else { return }
            guard let tagPropertiesViewController = self.tagPropertiesViewController else { return }
            propertyView.addSubview(tagPropertiesViewController.view)
            tagPropertiesViewController.view.snp.makeConstraints { (make) in
                make.edges.equalTo(propertyView)
            }
            self.addChildViewController(tagPropertiesViewController)
        }
    }

    var tagWithInfo: TagWithInfo? {
        didSet {
            tagPropertiesViewController?.tagWithInfo = tagWithInfo
        }
    }
    var tag: Tag? {
        return tagWithInfo?.data
    }
    
    static func fromStoryboard () -> NewViewController {
        return UIStoryboard.get("edit", identifier: "NewView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.contrainer?.layer.shadowColor = UIColor.black.cgColor
//        self.contrainer?.layer.shadowOffset = CGSize.zero
//        self.contrainer?.layer.shadowRadius = 5
//        self.contrainer?.layer.shadowOpacity = 0.5
//        self.contrainer?.layer.masksToBounds = false

        self.tagPropertiesViewController = TagPropertiesViewController.fromStoryboard()
        self.tagPropertiesViewController?.isNew = true
        
        let tag = Tag()
        tag.bindView(view: contrainer!)
        let tagWithInfo = TagWithInfo()
        tagWithInfo.name = String(format: NSLocalizedString("新建标签_%d", comment: "新建标签_%d"), API.shared.newTagsCount + 1)
        tagWithInfo.data = tag
        self.tagWithInfo = tagWithInfo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleButton?.setTitle(tagWithInfo?.name, for: .normal)
    }
    
    @objc @IBAction func showEdit () {
        let edit = EditViewController.fromStoryboard()
        edit.tagWithInfo = tagWithInfo
        guard var viewControllers = self.navigationController?.viewControllers else { return }
        viewControllers[viewControllers.count - 1] = edit
        self.navigationController?.setViewControllers(
            viewControllers, animated: true)
        
        API.shared.newTagsCount += 1
    }
}
