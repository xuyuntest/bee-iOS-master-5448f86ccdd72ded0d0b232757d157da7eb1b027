//
//  TemplatesViewController.swift
//  bee
//
//  Created by Herb on 2018/9/1.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {

    @IBOutlet var tabs: Tabs!
    @IBOutlet var tableView: UITableView!
    
    var tags: [TagWithInfo] = []
    var categories: [TagCategory] = [] {
        didSet {
            updateTabs()
        }
    }
    var currentTabIndex: Int = 0 {
        didSet {
            onTabIndexChanged()
        }
    }
    var isDeleting: Bool = false
    
    static func fromStoryboard () -> CategoriesViewController {
        return UIStoryboard.get("tag")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        onTabIndexChanged()
        tabs.delegate = self
        updateTabs()
        API.shared.getTagCategories { (categories, error) in
            if let categories = categories {
                self.categories = categories
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshMine()
    }
    
    func refreshMine () {
        if self.isDeleting {
            return
        }
        API.shared.getMyTags { (tags, error) in
            if let tags = tags {
                self.tags = tags
                if self.currentTabIndex == 0 {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func onTabIndexChanged () {
        if currentTabIndex == 0 {
            tableView.rowHeight = UITableViewAutomaticDimension
        } else {
            tableView.rowHeight = 73
        }
        tableView.reloadData()
    }
    
    func updateTabs () {
        var categoryNames = categories.map({ (category) -> String in
            return category.name
        })
        categoryNames.insert(NSLocalizedString("我的", comment: "我的"), at: 0)
        tabs?.setTabs(categoryNames)
    }
    
    @objc @IBAction func editTag (sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let tag = tags[indexPath.row]
        let edit = EditViewController.fromStoryboard()
        edit.tagWithInfo = tag
        self.navigationController?.pushViewController(edit, animated: true)
    }
    
    @objc @IBAction func deleteTag (sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let tag = tags[indexPath.row]
        guard let templateId = tag.template_id else { return }
        let confirm = UIAlertController(title: NSLocalizedString("删除标签", comment: "删除标签"), message: NSLocalizedString("确认要删除标签", comment: "确认要删除标签"), preferredStyle: UIAlertControllerStyle.alert)
        confirm.addAction(UIAlertAction(title: NSLocalizedString("删除", comment: "删除"), style: .destructive, handler: { (action: UIAlertAction!) in
            API.shared.deleteTag(templateId, callback: { (response, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "\(error)")
                    return
                }
                
                self.isDeleting = true
                self.tableView.beginUpdates()
                self.tags.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                DispatchQueue.main.async {
                    self.isDeleting = false
                }
            })
        }))
        confirm.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: "取消"), style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(confirm, animated: true, completion: nil)
    }
    
    @objc @IBAction func viewTag (sender: UIButton) {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let tag = tags[indexPath.row]
        let detail = TagDetailViewController.fromStoryboard()
        detail.tag = tag
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

extension CategoriesViewController: TabsDelegate {
    
    func onSelectTab(index: Int, tabs: Tabs) {
        currentTabIndex = index
    }
    
}

extension CategoriesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTabIndex == 0 {
            return tags.count
        }
        let sons = categories[currentTabIndex - 1].sons ?? []
        return sons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentTabIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! TagCell
            let tag = tags[indexPath.row]
            cell.setTag(tag, tableView: tableView, indexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SimpleCell
        let sons = categories[currentTabIndex - 1].sons ?? []
        let son = sons[indexPath.row]
        cell.valueLabel.text = son.name
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentTabIndex == 0 {
        } else {
            let sons = categories[currentTabIndex - 1].sons ?? []
            let son = sons[indexPath.row]
            
            let viewController = TagsInCategoryViewController.fromStoryboard()
            viewController.title = son.name
            viewController.categoryId = son.cate_id
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
