//
//  TagDetailViewController.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TagDetailViewController: UIViewController {
    
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var labels: [UILabel]!
    
    var tag: TagWithInfo? {
        didSet {
            syncTag ()
        }
    }
    
    static func fromStoryboard () -> TagDetailViewController {
        return UIStoryboard.get("tag", identifier: "TagDetailView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewImageView.layer.shadowColor = UIColor.black.cgColor
        previewImageView.layer.shadowOffset = CGSize.zero
        previewImageView.layer.shadowRadius = 5
        previewImageView.layer.shadowOpacity = 0.5
        previewImageView.layer.masksToBounds = false
    }
    
    func syncTag () {
        guard let tag = self.tag else { return }
        guard let qiniuUrl = tag.preview.qiniuURL else { return }
        let old = self.previewImageView.image
        self.previewImageView.af_setImage(withURL: qiniuUrl) { (response) in
            if let image = response.value, image !== old {
                let imageView = self.previewImageView!
                imageView.snp.remakeConstraints({ (make) in
                    make.height.equalTo(
                        imageView.snp.width).multipliedBy(
                            image.size.height / image.size.width)
                })
                imageView.superview?.layoutIfNeeded()
            }
        }
        self.labels[0].text = String(format: NSLocalizedString("标签名称：%@", comment: "标签名称：%@"), tag.name)
        if let realTag = tag.data {
            self.showTagInfo(realTag: realTag)
        } else if let templateId = tag.template_id {
            API.shared.getTag(templateId) { (tag, error) in
                if let realTag = tag?.data {
                    self.showTagInfo(realTag: realTag)
                }
            }
        }
    }
    
    func showTagInfo(realTag: Tag) {
        self.labels[1].text = String(format: NSLocalizedString("标签尺寸: %.1fmmx%.1fmm", comment: "标签尺寸: %.1fmmx%.1fmm"), realTag.width, realTag.height)
        if realTag.angel > 0 {
            self.labels[2].text = String(format: NSLocalizedString("打印方向：%d度", comment: "打印方向%d度"), realTag.angel)
        } else {
            self.labels[2].text = NSLocalizedString("打印方向：不旋转", comment: "打印方向：不旋转")
        }
        
        self.labels[3].text = String(format: NSLocalizedString("纸张间隔：%@", comment: "纸张间隔：%@"), realTag.pageIntervalType.label)
        let createdAt = API.shared.dateFormatter.string(from: realTag.createdAt)
        self.labels[4].text = String(format: NSLocalizedString("保存时间：%@", comment: "保存时间：%@"), createdAt)
    }
    
    @objc @IBAction func editTag (sender: UIButton) {
        let edit = EditViewController.fromStoryboard()
        edit.tagWithInfo = tag
        self.navigationController?.pushViewController(edit, animated: true)
    }
    
    @objc @IBAction func deleteTag (sender: UIButton) {
        guard let templateId = tag?.template_id else { return }
        let confirm = UIAlertController(title: NSLocalizedString("删除标签", comment: "删除标签"), message: NSLocalizedString("确认要删除标签", comment: "确认要删除标签"), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: NSLocalizedString("删除", comment: "删除"), style: .destructive, handler: { (action: UIAlertAction!) in
            API.shared.deleteTag(templateId, callback: { (response, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "\(error)")
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
            })
        }))
        confirm.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: "取消"), style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirm, animated: true, completion: nil)
    }
    
    @objc @IBAction func printTag (sender: UIButton) {
        PrintSettingViewController.print(tag: tag, from: self)
    }
}
