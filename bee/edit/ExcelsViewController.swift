//
//  ExcelViewController.swift
//  bee
//
//  Created by Herb on 2018/8/25.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import QuickLook

protocol ExcelsViewControllerProtocol: class {
    func onSelectExcel(_ url: URL, excelViewController: ExcelsViewController)
}

class ExcelsViewController: UITableViewController {
    
    var delegate: ExcelsViewControllerProtocol? = nil

    var urls: [URL] = [] {
        didSet {
            guard let tableView = tableView else { return }
            tableView.reloadData()
        }
    }
    
    static func fromStoryboard () -> ExcelsViewController {
        return UIStoryboard.get("edit", identifier: "ExcelsView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urls = FilesManager.shared.listExcels()
    }
    
    @objc @IBAction func preview(sender: UIButton)  {
        guard let cell = sender.nearestCell else { return }
        guard let indexPath = self.tableView?.indexPath(for: cell) else { return }
        let url = urls[indexPath.row]
        let qlPreviewController = ExcelPreviewViewController()
        qlPreviewController.url = url
        self.navigationController?.pushViewController(
            qlPreviewController, animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SimpleCell
        let url = urls[indexPath.row]
        cell.valueLabel?.text = url.lastPathComponent
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = urls[indexPath.row]
        delegate?.onSelectExcel(url, excelViewController: self)
        self.navigationController?.popViewController(animated: true)
    }
}
