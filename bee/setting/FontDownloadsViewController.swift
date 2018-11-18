//
//  FontDownloadsViewController.swift
//  bee
//
//  Created by Herb on 2018/10/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class FontCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var progressView: UIView!
    @IBOutlet var progressLabel: UILabel!
    
    var progressInnerView: UIView {
        if let view = progressView.subviews.first, view != progressLabel {
            return view
        }
        let view = UIView()
        progressView.insertSubview(view, at: 0)
        view.snp.makeConstraints({ (make) in
            make.leading.equalTo(progressView)
            make.top.equalTo(progressView)
            make.bottom.equalTo(progressView)
            make.width.equalTo(0)
        })
        view.backgroundColor = UIColor("#fabe00")
        return view
    }
    
    var progress: Double = -1 {
        didSet {
            if progress < 0 || progress >= 1 {
                downloadButton.isSelected = progress >= 1
                progressView.isHidden = true
                return
            }
            progressLabel.text = String(format: "%.0f%%%", progress*100)
            progressInnerView.snp.updateConstraints { (make) in
                let width = self.progressView.bounds.size.width
                make.width.equalTo(width * CGFloat(progress))
            }
            progressView.isHidden = false
        }
    }
}

class FontDownloadsViewController: UITableViewController {
    
    var fonts = [Font]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.shared.getFonts { (fonts, error) in
            if let fonts = fonts {
                self.fonts = fonts
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fonts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FontCell
        let font = fonts[indexPath.row]
        cell.nameLabel.text = font.localizedName
        if FontCacher.shared.isExist(font: font) {
            cell.progress = 1
        } else {
            cell.progress = font.progress ?? -1
        }
        return cell
    }
    
    @objc @IBAction func onDownload (sender: UIButton) {
        guard let cell = sender.nearestCell as? FontCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let font = fonts[indexPath.row]
        if font.progress ?? -1 >= 0.0 {
            return
        }
        if FontCacher.shared.isExist(font: font) {
            cell.progress = 1
            return
        }
        
        cell.progress = 0
        FontCacher.shared.cacheFont(font: font, progress: { (progress) in
            font.progress = progress.fractionCompleted
            cell.progress = progress.fractionCompleted
        }) { (key, filePath, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                return
            }
            cell.progress = 1
        }
    }
}
