//
//  ExcelViewController.swift
//  bee
//
//  Created by Herb on 2018/8/25.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import QuickLook

protocol PrinterButtonDelegate: class {
    
    func connecting(printerButton: PrinterButton, printer: CBPrinterProtocol)
    
}

class PrinterButton: UIView {
    
    var button: UIButton!
    var selectedButton: UIButton!
    var emptyTip: String = NSLocalizedString("无", comment: "无")
    
    weak var delegate: PrinterButtonDelegate? = nil
    
    var printer: CBPrinterProtocol? {
        didSet {
            if let printer = printer {
                button.setTitle(String(format: NSLocalizedString("设备名称: %@", comment: "设备名称: %@"), printer.getName()), for: .normal)
            } else {
                button.setTitle(emptyTip, for: .normal)
            }
        }
    }
    
    var isSelected: Bool {
        get {
            return self.selectedButton.isSelected
        }
        set {
            self.selectedButton.isSelected = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup () {
        self.button = UIButton()
        self.button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.button.setTitleColor(UIColor("#1a1a1a"), for: .normal)
        self.button.contentHorizontalAlignment = .left
        self.button.addTarget(self, action: #selector(PrinterButton.connect), for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        self.selectedButton = UIButton()
        self.selectedButton.setImage(UIImage(named: "select"), for: .selected)
        self.addSubview(self.selectedButton)
        selectedButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
    
    @objc func connect () {
        guard let printer = printer else { return }
        delegate?.connecting(printerButton: self, printer: printer)
    }
}

class PrinterCell: UITableViewCell {

    @IBOutlet weak var contrainerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    func setPrinters(_ printers: [CBPrinterProtocol?], current: CBPrinterProtocol?, delegate: PrinterButtonDelegate, emptyTip: String = NSLocalizedString("无", comment: "无")) {
        var printerButtons = [PrinterButton]()
        for view in contrainerView.subviews {
            if let printerButton = view as? PrinterButton {
                printerButtons.append(printerButton)
            }
        }

        var lastPrinterButton: PrinterButton?
        for (i, printer) in printers.enumerated() {
            var printerButton: PrinterButton? = nil
            if i < printerButtons.count {
                printerButton = printerButtons[i]
            }
            if printerButton == nil {
                let newButton = PrinterButton()
                contrainerView.addSubview(newButton)
                newButton.snp.makeConstraints { (make) in
                    if let last = lastPrinterButton {
                        make.top.equalTo(last.snp.bottom).offset(1)
                    } else {
                        make.top.equalTo(lineView.snp.bottom).offset(5.5)
                    }
                    make.leading.equalTo(lineView)
                    make.trailing.equalTo(lineView)
                }
                printerButton = newButton
            }
            
            printerButton?.isHidden = false
            printerButton?.delegate = delegate
            printerButton?.emptyTip = emptyTip
            printerButton?.printer = printer
            let printerName = printer?.getName() ?? ""
            if printerName.isEmpty {
                printerButton?.isSelected = false
            } else {
                printerButton?.isSelected = (current?.getName() ?? "") == printerName
            }
            lastPrinterButton = printerButton
        }
        
        if printers.count < printerButtons.count {
            for i in printers.count..<printerButtons.count {
                let printerButton = printerButtons[i]
                printerButton.isHidden = true
            }
        }
    }
}

class PrintersViewController: UIViewController {
    
    @IBOutlet weak var tabs: Tabs?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tipView: UIView?
    
    var expanded = Set<Int>([0, 1])
    
    static func fromStoryboard () -> PrintersViewController {
        return UIStoryboard.get("printer")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabs?.setTabs([NSLocalizedString("蓝牙", comment: "蓝牙"), "Wifi"])
        tabs?.delegate = self
        
        PrintersManager.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PrintersManager.shared.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PrintersManager.shared.stopScan()
    }
}

extension PrintersViewController: TabsDelegate {
    func onSelectTab(index: Int, tabs: Tabs) {
        tableView?.isHidden = index != 0
        tipView?.isHidden = index != 1
    }
}

extension PrintersViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PrinterCell
        var printers: [CBPrinterProtocol?]
        var empty = NSLocalizedString("无", comment: "无")
        if indexPath.row == 0 {
            cell.categoryLabel.text = NSLocalizedString("当前连接的打印机", comment: "当前连接的打印机")
            empty = NSLocalizedString("没有连接打印机", comment: "没有连接打印机")
            printers = [PrintersManager.shared.currentPrinter]
        } else if indexPath.row == 1 {
            cell.categoryLabel.text = NSLocalizedString("搜索到的打印机", comment: "搜索到的打印机")
            printers = PrintersManager.shared.printers
        } else if indexPath.row == 2 {
            cell.categoryLabel.text = NSLocalizedString("连接过的打印机", comment: "连接过的打印机")
            printers = PrintersManager.shared.recentPrinters
        } else {
            printers = []
        }
        if printers.isEmpty {
            printers = [nil]
        }
        cell.lineView.isHidden = !expanded.contains(indexPath.row)
        cell.setPrinters(printers, current: PrintersManager.shared.currentPrinter, delegate: self, emptyTip: empty)
        return cell
    }
}

extension PrintersViewController: PrinterButtonDelegate {
    func connecting(printerButton: PrinterButton, printer: CBPrinterProtocol) {
        SVProgressHUD.showProgress(-1, status: String(format: NSLocalizedString("正在连接打印机 %@...", comment: "正在连接打印机 %@..."), printer.getName()))
        PrintersManager.shared.connect(printer) {
            SVProgressHUD.showSuccess(withStatus: String(format: NSLocalizedString("已连接%@", comment: "已连接%@"), printer.getName()))
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PrintersViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expanded.contains(indexPath.row) {
            let count: Int
            if indexPath.row == 1 {
                count = PrintersManager.shared.printers.count
            } else if indexPath.row == 2 {
                count = PrintersManager.shared.recentPrinters.count
            } else {
                count = 1
            }
            let countFloat: CGFloat
            if count <= 0 {
                countFloat = 1
            } else {
                countFloat = CGFloat(count)
            }
            return 5 + 51 + 5.5 + 34 * countFloat + 1 * (countFloat - 1) + 10.5 + 5
        } else {
            return tableView.rowHeight
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if expanded.contains(row) {
            expanded.remove(row)
        } else {
            expanded.insert(row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension PrintersViewController: PrintersManagerDelegate {
    func findedNewPrinter(printersManager: PrintersManager, newPrinter: CBPeripheral?) {
        tableView?.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }
}
