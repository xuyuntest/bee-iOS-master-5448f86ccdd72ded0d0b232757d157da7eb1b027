//
//  PrintersManager.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

protocol CBPrinterProtocol {
    func getName () -> String
}

class CBPrinter: Codable, CBPrinterProtocol {
    
    var name: String = ""
    
    func getName() -> String {
        return self.name
    }
}

extension CBPeripheral: CBPrinterProtocol {
    
    func getName() -> String {
        return self.name ?? ""
    }
}

protocol PrintersManagerDelegate: class {
    func findedNewPrinter(printersManager: PrintersManager, newPrinter: CBPeripheral?)
}

class PrintersManager: NSObject {
    static let shared = PrintersManager()
    
    var _printers: [CBPeripheral] = []
    
    var printers: [CBPeripheral] {
        get {
            var printers = _printers
            if let currentPrinter = self.currentPrinter {
                if let _ = printers.index(where: { (aPrinter) -> Bool in
                    return aPrinter.identifier == currentPrinter.identifier
                }) {
                    return printers
                }
                printers.append(currentPrinter)
            }
            return printers
        }
        
        set {
            _printers = newValue
        }
    }
    var foundedPrinters: [CBPeripheral] = []
    var recentPrinters: [CBPrinter] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "recent_printers") else { return [] }
            let tags = (try? JSONDecoder().decode([CBPrinter].self, from: data)) ?? []
            return tags
        }
        set {
            let limit = 20
            let value: [CBPrinter]
            if newValue.count > limit {
                value = Array(newValue[0..<limit])
            } else {
                value = newValue
            }
            if let data = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(data, forKey: "recent_printers")
            }
        }
    }
    var _currentPrinter: CBPeripheral? = nil
    var currentPrinter: CBPeripheral? {
        get {
            if !self.isConnected() {
                return nil
            }
            return _currentPrinter
        }
        
        set {
            _currentPrinter = newValue
        }
    }
    var tasks: [(() -> Void)] = []
    var lastResponse: String = ""
    weak var delegate: PrintersManagerDelegate?
    
    private override init () {
        super.init()
        guard let api = FscBleCentralApi.share() else { return }
        api.moduleType = BLEMODULE
        load()
    }
    
    private func addPrinter(_ printer: CBPeripheral) {
        if let _ = self.foundedPrinters.index(where: { (aPrinter) -> Bool in
            return aPrinter.identifier == printer.identifier
        }) {
        } else {
            self.foundedPrinters.append(printer)
        }
        
        if let _ = self.printers.index(where: { (aPrinter) -> Bool in
            return aPrinter.identifier == printer.identifier
        }) {
        } else {
            self.printers.append(printer)
            self.delegate?.findedNewPrinter(
                printersManager: self, newPrinter: printer)
        }
    }
    
    public func startScan () {
        guard let api = FscBleCentralApi.share() else { return }
        api.startScan()
    }
    
    public func stopScan () {
        guard let api = FscBleCentralApi.share() else { return }
        self.printers.removeAll()
        self.delegate?.findedNewPrinter(
            printersManager: self, newPrinter: nil)
        api.stopScan()
    }
    
    public func load () {
        guard let api = FscBleCentralApi.share() else { return }
        api.isBtEnabled({ (manager) in
            if manager?.state != CBManagerState.poweredOn {
                SVProgressHUD.showError(withStatus: NSLocalizedString("请打开蓝牙", comment: "请打开蓝牙"))
            }
        })
        api.blePeripheralFound { (manager, printer: CBPeripheral!, data, RSSI) in
            guard let rssiInt = RSSI?.intValue else { return }
            if rssiInt >= 0 || rssiInt <= -100 {
                return
            }
            guard var name = printer.name else {
                return
            }
            name = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if name.isEmpty {
                return
            }
            if let printer = printer {
                self.addPrinter(printer)
            }
        }
        
        api.packetReceived { (printer, characteristic, error) in
            let text: String
            if let data = characteristic?.value, let str = String(bytes: data, encoding: .utf8) {
                text = str
            } else {
                text = ""
            }
            self.lastResponse = text
        }
        
        api.blePeripheralConnected { (manager, printer) in
            api.discoverServices()
            self.checkReadyStatus()
            
            if let printer = self.currentPrinter {
                let newPrinter = CBPrinter()
                newPrinter.name = printer.name ?? ""
                self.recentPrinters.append(newPrinter)
            }
        }
        
        api.blePeripheralDisonnected { (manager, printer, error) in
            if self.currentPrinter == printer {
                SVProgressHUD.showError(withStatus: NSLocalizedString("链接断开, 请检查硬件连接", comment: "链接断开, 请检查硬件连接"))
            }
            self.currentPrinter = nil
        }
    }
    
    public func connect (_ selectedPrinter: CBPrinterProtocol, task: @escaping (() -> Void)) {
        var possiblePrinter: CBPeripheral? = nil
        if let realPrinter = selectedPrinter as? CBPeripheral {
            possiblePrinter = realPrinter
        } else {
            for aPrinter in self.foundedPrinters {
                if aPrinter.getName() == selectedPrinter.getName() {
                    possiblePrinter = aPrinter
                    break
                }
            }
        }
        guard let printer = possiblePrinter else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("没有找到设备", comment: "没有找到设备"))
            return
        }
        
        if self.isReady() && self.currentPrinter == printer {
            task()
        } else {
            tasks.append(task)
            if self.isConnecting() && self.currentPrinter == printer {
                return
            }
            currentPrinter = printer
            guard let api = FscBleCentralApi.share() else { return }
            api.disconnect()
            api.connect(printer)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15)) {
                if self.isReady() || self.currentPrinter == nil {
                    return
                }
                
                self.currentPrinter = nil
                if let api = FscBleCentralApi.share() {
                    api.disconnect()
                }
                SVProgressHUD.showError(withStatus: NSLocalizedString("连接超时", comment: "连接超时"))
            }
        }
    }
    
    public func isReady () -> Bool {
        guard let api = FscBleCentralApi.share() else { return false }
        let status = api.getState()
        return status == FSCBT_STATUS_READY_TO_TRANSFER
    }
    
    public func isConnecting() -> Bool {
        guard let api = FscBleCentralApi.share() else { return false }
        let status = api.getState()
        return status == FSCBT_STATUS_CONNECTING || status == FSCBT_STATUS_CONNECTED || status == FSCBT_STATUS_SEARCHING_SERVICES
    }
    
    public func isConnected() -> Bool {
        guard let api = FscBleCentralApi.share() else { return false }
        let status = api.getState()
        return status == FSCBT_STATUS_CONNECTED || status == FSCBT_STATUS_READY_TO_TRANSFER || status == FSCBT_STATUS_SEARCHING_SERVICES
    }
    
    @objc private func checkReadyStatus() {
        guard let api = FscBleCentralApi.share() else { return }
        if api.getState() != FSCBT_STATUS_READY_TO_TRANSFER {
            self.perform(#selector(
                PrintersManager.checkReadyStatus), with: nil, afterDelay: 1)
            return
        }
        let tasks = self.tasks
        self.tasks = []
        tasks.forEach { (task) in
            task()
        }
    }
    
    public func printTag(_ tag: TagWithInfo, concentration: Int, pagesCount: Int, copiesCount: Int, autoPaging: Bool, printer: CBPeripheral, view: UIView) {
        if self.isReady(), self.currentPrinter == printer {
            self.printSafe(tag, concentration: concentration, pagesCount:pagesCount, copiesCount:copiesCount, autoPaging:autoPaging, view: view)
        } else {
            self.connect(printer, task: {
                self.printWithStatusCheck(tag, concentration: concentration, pagesCount:pagesCount, copiesCount:copiesCount, autoPaging:autoPaging, view: view)
            })
            SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在连接 ...", comment: "正在连接 ..."))
        }
    }
    
    private func printWithStatusCheck (_ tag: TagWithInfo, concentration: Int, pagesCount: Int, copiesCount: Int, autoPaging: Bool, view: UIView) {
        let printer = Printer()
        guard let api = FscBleCentralApi.share() else { return }
        if let data =
            printer.checkStatus(0) {
            api.syncSend(data, withResponse: true)
            api.readResponse { (characteristic) in
                if let data = characteristic?.value {
                    if data[1] == 0x01 {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("打印机无纸, 请放入打印纸", comment: "打印机无纸, 请放入打印纸"))
                        return
                    }
                    if data[2] == 0x01 {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("打印机欠压, 请检查电压", comment: "打印机欠压, 请检查电压"))
                        return
                    }
                    if data[3] == 0x01 {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("打印机过热, 请稍后再打印", comment: "打印机过热, 请稍后再打印"))
                        return
                    }
                    self.printSafe(tag, concentration: concentration, pagesCount:pagesCount, copiesCount:copiesCount, autoPaging:autoPaging, view: view)
                } else {
                    SVProgressHUD.showError(withStatus: NSLocalizedString("获取打印机状态失败", comment: "获取打印机状态失败"))
                }
            }
        }
    }
    
    private func printSafe (_ tag: TagWithInfo, concentration: Int, pagesCount: Int, copiesCount: Int, autoPaging: Bool, view: UIView) {
        if let tag = tag.data {
            self.printTagCopy(tag, concentration: concentration, pagesCount:pagesCount, copiesCount:copiesCount, autoPaging:autoPaging, view: view)
        } else {
            API.shared.getTag(tag.template_id!) { (tagWithInfo, error) in
                if let tagWithInfo = tagWithInfo, let tag = tagWithInfo.data {
                    self.printTagCopy(tag, concentration: concentration, pagesCount:pagesCount, copiesCount:copiesCount, autoPaging:autoPaging, view: view)
                } else {
                    SVProgressHUD.showError(withStatus: "\(String(describing: error))")
                }
            }
        }
    }
    
    private func printTagCopy (_ tag: Tag, concentration: Int, pagesCount: Int, copiesCount: Int, autoPaging: Bool, view: UIView) {
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在打印 ...", comment: "正在打印 ..."))
        
        self.lastResponse = ""
        let printer = Printer()
        guard let api = FscBleCentralApi.share() else { return }
        if let data =
            printer.setSpeed(2, level: Int32(tag.printSpeed)) {
            api.syncSend(data, withResponse: true)
        }
        if let data =
            printer.setDensity(2, level: Int32(concentration)) {
            api.syncSend(data, withResponse: true)
        }
        if let data = printer.startPrintjob() {
            api.syncSend(data, withResponse: true)
        }
        if let data = printer.setPaperType(0x02, type: tag.pageIntervalType.papaerTypeValue) {
            api.syncSend(data, withResponse: true)
        }
        if tag.pageIntervalType == .gap {
            if let data = printer.adjustPositionAuto(0x51) {
                api.syncSend(data, withResponse: true)
            }
        }
        
        var currentCopy = 0
        var currentPage = 0
        func callback (_ error: Error?) -> Void {
            if let error = error {
                SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("打印失败: %s", comment: "打印失败: %s"), error.localizedDescription))
                return
            }
            if currentPage >= pagesCount {
                currentCopy += 1
                if currentCopy >= copiesCount {
                    if tag.pageIntervalType == .gap {
                        if let data = printer.adjustPositionAuto(0x50) {
                            api.syncSend(data, withResponse: true)
                        }
                    } else if tag.pageIntervalType == .continuous {
                        if let data = printer.adjustPosition(0x01, distance: 10) {
                            api.syncSend(data, withResponse: true)
                        }
                    }
                    if let data = printer.stopPrintjob() {
                        api.syncSend(data, withResponse: true)
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: NSLocalizedString("打印成功", comment: "打印成功"))
                    return
                }
                currentPage = 0
            }
            SVProgressHUD.showProgress(-1, status: String(format: NSLocalizedString("正在打印 %d/%d ...", comment: "正在打印 %d/%d ..."), currentPage + 1, pagesCount))
            self.printTagPageAtIndex(tag, page: currentPage, view: view, callback: callback)
            currentPage += 1
        }
        
        callback(nil)
    }
    
    func printTagPageAtIndex (_ tag: Tag, page: Int, view: UIView, callback: @escaping ((Error?) -> Void)) {
        let cloned = tag.clone()
        for item in cloned.items {
            guard let textItem = item.textItem else { continue }
            
            // 递增
            textItem.stepText(page)

            // excel
            let excel = textItem.excel
            if excel.url.isEmpty || excel.column.isEmpty || excel.worksheet.isEmpty {
                continue
            }
            
            let excelExt = URL(string: excel.name)!.pathExtension
            FileCacher.shared.cacheLocalFile(url: excel.url.qiniuURL!
            , ext: excelExt) { (_, filePath, error) in
                if let filePath = filePath {
                    guard let document = BRAOfficeDocumentPackage.open(filePath) else {
                        SVProgressHUD.showError(withStatus: NSLocalizedString("Excel 文件损坏", comment: "Excel 文件损坏"))
                        return
                    }
                    guard let sheet = document.workbook.worksheetNamed(excel.worksheet) else {
                        SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("找不到表: %@", comment: "找不到表: %@"), excel.worksheet))
                        return
                    }
                    var possibleExcelColumn: Character?
                    for c in Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ") {
                        let cellRef = String(format: "%@1", String(c))
                        let cell = sheet.cell(forCellReference: cellRef)
                        let cellValue = cell?.stringValue() ?? ""
                        if cellValue == excel.column {
                            possibleExcelColumn = c
                            break
                        }
                    }
                    guard let excelColumn = possibleExcelColumn else {
                        SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("找不到列: %d", comment: "找不到列: %d"), excel.column))
                        return
                    }
                    
                    let cellRef = String(format: "%@%d", String(excelColumn), page + 2)
                    let cell = sheet.cell(forCellReference: cellRef)
                    let cellValue = cell?.stringValue() ?? ""
                    textItem.text = cellValue
                }
            }
        }
        
        let render = RenderView()
        render.showBackground = false
        render.render(cloned, view: view) { (image, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                callback(error)
                return
            }
            let printer = Printer()
            if let api = FscBleCentralApi.share() {
                if let data = printer.drawGraphic(image) {
                    api.syncSend(data, withResponse: true)
                }
                if let data = printer.printerLocation(cloned.pageIntervalType.value, type: 0) {
                    api.syncSend(data, withResponse: true)
                }
//                var error: Error? = nil
//                while (true) {
//                    if (self.lastResponse.contains("OK")) {
//                        break;
//                    }
//                    if (self.lastResponse.contains("ER")) {
//                        error = SimpleError.string(self.lastResponse)
//                        brdfa u yeak
//                    }
//                }
//                callback(error)
                callback(nil)
                self.lastResponse = ""
                
            }
        }
    }
}
