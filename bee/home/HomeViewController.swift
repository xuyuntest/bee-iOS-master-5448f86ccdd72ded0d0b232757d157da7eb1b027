//
//  HomeViewController.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var previewImageView: UIImageView!
    
    public func setTag (_ tag: TagWithInfo, collectionView: UICollectionView, indexPath: IndexPath) {
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
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet var currentTagLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var emptyView: UIView!
    
    @IBOutlet var printerStatus: UIButton!
    
    var observer: Any?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("Unauthorized"), object: nil, queue: OperationQueue.main) { (notification) in
            self.performSegue(withIdentifier: "showLoginView", sender: self)
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var tags = [TagWithInfo]() {
        didSet {
            emptyView?.isHidden = !tags.isEmpty
            currentTagLabel?.isHidden = tags.isEmpty
            collectionView?.isHidden = tags.isEmpty
            pageControl?.isHidden = tags.isEmpty
            if let collectionView = collectionView, !collectionView.isHidden {
                pageControl.numberOfPages = tags.count
                refreshCurrentTag()
                collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        self.printerStatus.isSelected = PrintersManager.shared.isReady() && PrintersManager.shared.currentPrinter != nil
        if self.printerStatus.isSelected, let printer = PrintersManager.shared.currentPrinter, let name = printer.name {
            self.printerStatus.setTitle(String(format: NSLocalizedString("已连接到%@打印机", comment: "已连接到%@打印机"), name), for: .selected)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if API.shared.token.isEmpty {
            self.performSegue(withIdentifier: "showLoginView", sender: self)
        } else {
            self.tags = API.shared.recentTags
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let height = collectionView.bounds.size.height
        if layout.itemSize.height == height {
            return
        }
        let width = collectionView.bounds.size.width * 325.0/375.0
        layout.itemSize = CGSize(width: width, height: height)
    }
    
    @objc @IBAction func showSetting () {
        let viewController = SettingViewController.fromStoryboard()
        self.navigationController?.pushViewController(
            viewController, animated: true)
    }
    
    @objc @IBAction func showTemplates () {
        let viewController = CategoriesViewController.fromStoryboard()
        self.navigationController?.pushViewController(
            viewController, animated: true)
    }
    
    @IBAction func scan () {
        let viewController = ScanViewController.fromStoryboard()
        viewController.callback = {(text: String) -> Bool in
            API.shared.getTag(tag: text, callback: { (tagWithInfo, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "\(error)")
                    return
                }
                guard let tagWithInfo = tagWithInfo else {
                    SVProgressHUD.showError(withStatus: NSLocalizedString("没有找到", comment: "没有找到"))
                    return
                }
                
                let edit = EditViewController.fromStoryboard()
                edit.tagWithInfo = tagWithInfo
                var viewControllers = self.navigationController?.viewControllers ?? []
                viewControllers.removeLast()
                viewControllers.append(edit)
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            })
            return false
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc @IBAction func printCurrentTag () {
        let page = self.pageControl.currentPage
        let tag: TagWithInfo?
        if page < self.tags.count {
            tag = self.tags[page]
        } else {
            tag = nil
        }
        PrintSettingViewController.print(tag: tag, from: self)
    }
    
    @objc @IBAction func createTag () {
        let new = NewViewController.fromStoryboard()
        self.navigationController?.pushViewController(new, animated: true)
    }
    
    func refreshCurrentTag () {
        let page = self.pageControl.currentPage
        let tag = self.tags[page]
        let postFix: String
        if self.tags.count > 1 {
            postFix = " \(page + 1)/\(self.pageControl.numberOfPages)"
        } else {
            postFix = ""
        }
        currentTagLabel.text = "\(tag.name)\(postFix)"
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TagCollectionViewCell
        let tag = self.tags[indexPath.row]
        cell.setTag(tag, collectionView: collectionView, indexPath: indexPath)
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayoutCentered {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = self.tags[indexPath.row]
        let detail = TagDetailViewController.fromStoryboard()
        detail.tag = tag
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayoutCentered, pageChanged page: Int) {
        self.pageControl.currentPage = page
        refreshCurrentTag()
    }
}
