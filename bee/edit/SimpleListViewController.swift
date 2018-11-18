//
//  SimpleListViewController.swift
//  bee
//
//  Created by Herb on 2018/8/25.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import QuickLook

protocol SimpleListViewControllerDelegate: class {
    
    func didSelectText(simpleListViewController: SimpleListViewController, text: String)
}

class SimpleListViewController: UITableViewController {
    
    weak var delegate: SimpleListViewControllerDelegate? = nil
    
    var texts: [String] = [] {
        didSet {
            guard let tableView = tableView else { return }
            tableView.reloadData()
        }
    }
    var text: String = ""
    
    static func fromStoryboard () -> SimpleListViewController {
        return UIStoryboard.get("edit", identifier: "SimpleListView")
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SimpleCell
        let text = texts[indexPath.row]
        cell.valueLabel.text = text
        if self.text == text {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = texts[indexPath.row]
        if self.text == text {
            return
        }
        self.text = text
        delegate?.didSelectText(simpleListViewController: self, text: text)
    }
}
