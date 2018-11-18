//
//  TagsInCategoryViewController.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import AlamofireImage

class TagCell: UITableViewCell {
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var lockButton: UIButton?
    @IBOutlet var favButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        previewImageView.layer.shadowColor = UIColor.black.cgColor
        previewImageView.layer.shadowOffset = CGSize.zero
        previewImageView.layer.shadowRadius = 5
        previewImageView.layer.shadowOpacity = 0.5
        previewImageView.layer.masksToBounds = false
    }
    
    func setTag (_ tag: TagWithInfo, tableView: UITableView, indexPath: IndexPath) {
        guard let qiniuUrl = tag.preview.qiniuURL else { return }
        self.lockButton?.isHidden = !(tag.self_created ?? false)
        let old = self.previewImageView.image
        self.previewImageView.af_setImage(withURL: qiniuUrl, placeholderImage: UIImage(named: "tag-placeholder")) { (response) in
            if let image = response.value, image !== old {
                let imageView = self.previewImageView!
                imageView.snp.remakeConstraints({ (make) in
                    make.height.equalTo(
                        imageView.snp.width).multipliedBy(
                            image.size.height / image.size.width)
                })
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        self.nameLabel.text = tag.name
        self.sizeLabel.text = "\(tag.width ?? 0)mmx\(tag.height ?? 0)mm"
        self.lockButton?.isSelected = !tag.isPublic
    }
}

class TagsInCategoryViewController: UITableViewController {
    
    var categoryId: String = "" {
        didSet {
            if categoryId.isEmpty {
                return
            }
            refresh()
        }
    }
    var tags: [TagWithInfo] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    static func fromStoryboard () -> TagsInCategoryViewController {
        return UIStoryboard.get("tag", identifier: "TagsInCategoryView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh () {
        API.shared.getTagInCategory(categoryId) { (tags, error) in
            if let tags = tags?.templates {
                self.tags = tags
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TagCell
        let tag = tags[indexPath.row]
        cell.setTag(tag, tableView: tableView, indexPath: indexPath)
        return cell
    }
    
    @objc @IBAction func onFav (sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let tag = tags[indexPath.row]
        guard let templateId = tag.template_id else { return }
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在收藏 ...", comment: "正在收藏 ..."))
        API.shared.forkTag(templateId) { (tag, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                return
            }
            sender.isSelected = true
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("已收藏到我的标签", comment: "已收藏到我的标签"))
        }
    }
    
    @objc @IBAction func onLock (sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let tag = tags[indexPath.row]
        guard let templateId = tag.template_id else { return }
        API.shared.toggleTagPublic(templateId, categoryId: categoryId, isPublic: !tag.isPublic) { (tag, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
            }
        }
    }
}
