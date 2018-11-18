//
//  IconsViewController.swift
//  bee
//
//  Created by Herb on 2018/9/13.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class LogoButton: UIButton {
    var logo: Logo? = nil
}

class IconCell: UITableViewCell {
    
    @IBOutlet var expandButton: UIButton!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var seperator: UIView!
    @IBOutlet var contrainer: UIView!
    
    func setCategory(_ category: TagCategory, logos: [String: [Logo]]?, expand: Bool, target: IconsViewController) {
        self.categoryLabel.text = category.name
        self.expandButton.isSelected = expand
        
        var tobeDeletes: [UIView] = []
        if contrainer.subviews.count > 3 {
            for i in 3..<contrainer.subviews.count {
                tobeDeletes.append(contrainer.subviews[i])
            }
            tobeDeletes.forEach { (view) in
                view.removeFromSuperview()
            }
        }
        
        let sons = category.sons ?? []
        for son in sons{
            let view = UIView()
            contrainer.addSubview(view)
            view.snp.remakeConstraints { (make) in
                make.leading.equalTo(contrainer)
                make.trailing.equalTo(contrainer)
                make.top.equalTo(
                    contrainer.subviews[
                        contrainer.subviews.count - 2].snp.bottom).offset(10)
            }
            
            let photos = logos?[son.cate_id] ?? []
            if photos.isEmpty {
                view.snp.makeConstraints { (make) in
                    make.height.equalTo(0)
                }
            } else {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 12)
                label.textColor = UIColor("#1a1a1a")
                label.text = son.name
                view.addSubview(label)
                label.snp.remakeConstraints { (make) in
                    make.leading.equalTo(view).offset(20)
                    make.top.equalTo(view).offset(19)
                    make.width.equalTo(100)
                }
                
                let iconsView = UIView()
                view.addSubview(iconsView)
                iconsView.snp.remakeConstraints { (make) in
                    make.leading.equalTo(
                        label.snp.trailing).offset(10)
                    make.trailing.equalTo(view).offset(-22)
                    make.top.equalTo(view)
                    make.bottom.equalTo(view)
                }
                
                for (i, photo) in photos.enumerated() {
                    let imageView = LogoButton()
                    imageView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                    imageView.imageView?.contentMode = .scaleAspectFit
                    imageView.logo = photo
                    imageView.addTarget(target, action: #selector(IconsViewController.selectLogo(sender:)), for: .touchUpInside)

                    if let qiniuUrl = photo.key.qiniuURL {
                        imageView.af_setImage(for: .normal, url: qiniuUrl)
                    }
                    iconsView.addSubview(imageView)
                    imageView.snp.remakeConstraints { (make) in
                        make.width.equalTo(
                            iconsView).dividedBy(4)
                        make.height.equalTo(40)
                        let column = i%4
                        if column == 0 {
                            make.leading.equalTo(iconsView)
                        } else {
                            let lastView = iconsView.subviews[iconsView.subviews.count - 2]
                            make.leading.equalTo(
                                lastView.snp.trailing)
                        }
                        
                        let row: Int = i/4
                        if row > 0 {
                            let rowView = iconsView.subviews[(row - 1)*4]
                            make.top.equalTo(
                                rowView.snp.bottom).offset(20)
                        } else {
                            make.top.equalTo(iconsView)
                        }
                    }
                }
                if let last = iconsView.subviews.last {
                    last.snp.makeConstraints({ (make) in
                        make.bottom.equalTo(iconsView)
                    })
                }
            }
        }
    }
    
    static func heightForCategory(_ category: TagCategory, logos: [String: [Logo]]?, expand: Bool) -> CGFloat {
        guard let logos = logos else { return 0}
        var height: CGFloat = 58
        if expand {
            height += 1
            for son in category.sons ?? [] {
                let photos = logos[son.cate_id] ?? []
                if photos.isEmpty {
                    continue
                }
                let rows = ceil(CGFloat(photos.count)/4.0)
                height += 20 + 5
                height += rows * 40 + (rows - 1) * 20
            }
        }
        return height
    }
}

protocol IconsViewControllerDelegate: class {
    
    func iconsViewController(_ controller: IconsViewController, selectedLogo: Logo)
}

class IconsViewController: UITableViewController {
    
    weak var delegate: IconsViewControllerDelegate? = nil
    var expands = [String: Bool]()
    var logos = [String: [String: [Logo]]]() {
        didSet {
            tableView.reloadData()
        }
    }
    var categories: [TagCategory] = [] {
        didSet {
            for category in categories {
                if let sons = category.sons {
                    for son in sons {
                        API.shared.getLogos(son.cate_id) { (logos, error) in
                            guard let logos = logos else { return }
                            var childLogos: [String: [Logo]]
                            if let value = self.logos[category.cate_id] {
                                childLogos = value
                            } else {
                                childLogos = [String: [Logo]]()
                            }
                            childLogos[son.cate_id] = logos
                            self.logos[category.cate_id] = childLogos
                        }
                    }
                }
            }
        }
    }
    
    static func fromStoryboard () -> IconsViewController {
        return UIStoryboard.get("edit", identifier: "IconsView")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        API.shared.getLogoCategories { (categories, error) in
            if let categories = categories {
                self.categories = categories
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let category = categories[indexPath.row]
        return IconCell.heightForCategory(category, logos: logos[category.cate_id], expand: expands[category.cate_id, default: false])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! IconCell
        let category = categories[indexPath.row]
        cell.setCategory(category, logos: logos[category.cate_id], expand: expands[category.cate_id, default: false], target: self)
        return cell
    }

    @objc @IBAction func toggleExpand(sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let category = categories[indexPath.row]
        expands[category.cate_id] = !(expands[category.cate_id] ?? false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func selectLogo (sender: LogoButton) {
        guard let logo = sender.logo else { return }
        delegate?.iconsViewController(self, selectedLogo: logo)
        self.navigationController?.popViewController(animated: true)
    }
}
