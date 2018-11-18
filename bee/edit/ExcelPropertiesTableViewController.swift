//
//  ExcelPropertiesTableViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class ExcelPropertiesViewController: UITableViewController {

    @IBOutlet weak var filenameLabel: UILabel?
    @IBOutlet weak var worksheetLabel: UILabel?
    @IBOutlet weak var columnLabel: UILabel?
    
    var propertyViewController: PropertyViewController? {
        return self.parent as? PropertyViewController
    }
    
    var pendingUrl: URL? = nil
    var document: BRAOfficeDocumentPackage? = nil
    
    var excel: Excel? {
        didSet {
            guard let _ = excel else { return }
            sync()
        }
    }
    
    static func fromStoryboard () -> ExcelPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "ExcelPropertiesView")
    }
    
    func sync () {
        syncFilename()
        syncWorksheet()
        syncColumn()
    }
    
    func syncBack () {
        if let pendingUrl = pendingUrl {
            if pendingUrl.isFileURL {
                SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在上传 Excel 文件", comment: "正在上传 Excel 文件"))
                let filename = filenameLabel?.text ?? ""
                let ext =  URL(fileURLWithPath: filename).pathExtension
                FileCacher.shared.cacheLocalFile(url: pendingUrl, ext: ext) { (key, _, error) in
                    if let key = key {
                        self.excel?.url = key
                        SVProgressHUD.dismiss()
                    } else {
                        SVProgressHUD.showError(
                            withStatus: "\(String(describing: error))")
                    }
                }
            }
        } else {
            excel?.url = ""
        }
        excel?.name = filenameLabel?.text ?? ""
        excel?.worksheet = worksheetLabel?.text ?? ""
        excel?.column = columnLabel?.text ?? ""
    }
    
    func syncFilename () {
        let name = excel?.name ?? ""
        filenameLabel?.text = name.isEmpty ? NSLocalizedString("无", comment: "无") : name
    }
    
    func syncWorksheet () {
        let name = excel?.worksheet ?? ""
        worksheetLabel?.text = name.isEmpty ? NSLocalizedString("无", comment: "无") : name
    }
    
    func syncColumn () {
        let name = excel?.column ?? ""
        columnLabel?.text = name.isEmpty ? NSLocalizedString("无", comment: "无") : name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let excelsViewController = ExcelsViewController.fromStoryboard()
            excelsViewController.delegate = self
            self.navigationController?.pushViewController(
                excelsViewController, animated: true)
        } else {
            guard let document = document else { return }
            if (indexPath.row == 1) {
                let simpleListViewController = SimpleListViewController.fromStoryboard()
                simpleListViewController.title = NSLocalizedString("选择工作表", comment: "选择工作表")
                simpleListViewController.texts = document.workbook.sheets.map { (sheet) -> String in
                    let braSheet = sheet as? BRASheet
                    return braSheet?.name ?? ""
                }
                simpleListViewController.text = worksheetLabel?.text ?? ""
                propertyViewController?.addViewController(
                    simpleListViewController, confirmBlock: { () -> Bool in
                        self.worksheetLabel?.text = simpleListViewController.text
                        return true
                })
            } else if (indexPath.row == 2) {
                guard let sheetName = worksheetLabel?.text else { return }
                guard let sheet = document.workbook.worksheetNamed(sheetName) else { return }
                let simpleListViewController = SimpleListViewController.fromStoryboard()
                simpleListViewController.title = NSLocalizedString("选择列", comment: "选择列")
                var columnNames = [String]()
                for c in Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ") {
                    let cellRef = String(format: "%@1", String(c))
                    let cell = sheet.cell(forCellReference: cellRef)
                    let cellValue = cell?.stringValue() ?? ""
                    if cellValue.isEmpty {
                        continue
                    }
                    columnNames.append(cellValue)
                }
                
                simpleListViewController.texts = columnNames
                simpleListViewController.text = columnLabel?.text ?? ""
                propertyViewController?.addViewController(
                    simpleListViewController, confirmBlock: { () -> Bool in
                        self.columnLabel?.text = simpleListViewController.text
                        return true
                })
            }
        }
    }
}

extension ExcelPropertiesViewController: ExcelsViewControllerProtocol {
    func onSelectExcel(_ url: URL, excelViewController: ExcelsViewController) {
        pendingUrl = url
        filenameLabel?.text = url.lastPathComponent
        
        document = BRAOfficeDocumentPackage.open(url.path)
    }
}
