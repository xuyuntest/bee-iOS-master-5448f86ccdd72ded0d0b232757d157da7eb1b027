//
//  ViewController.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet weak var contrainer: UIView?
    @IBOutlet var views: [UIView]?
    
    @IBOutlet var barCodeItemView: UIView?
    @IBOutlet var qrcodeItemView: UIView?
    @IBOutlet var lineItemView: UIView?
    @IBOutlet var shapeItemView: UIView?
    @IBOutlet var timeItemView: UIView?
    @IBOutlet var imageItemView: UIView?
    @IBOutlet var tableItemView: UIView?
    
    @IBOutlet var textItemView: UIView?
    @IBOutlet var textItemTextView: UIView?
    
    @IBOutlet var textItemInitNumberView: UIView?
    @IBOutlet var textItemInitNumberLabel: UITextField?
    
    @IBOutlet var angelView: UIView?
    @IBOutlet var angelButtons: [UIButton]?
    @IBOutlet var otherAngelButton: UIButton?
    
    @IBOutlet var backwardHistoryButton: UIButton?
    @IBOutlet var forwardHistoryButton: UIButton?
    
    @IBOutlet var existView: UIView?
    
    @IBOutlet var selectionSwither: UIButton?
    @IBOutlet var selectionView: UIView?
    @IBOutlet var selectionRadios: [UIButton]?
    
    @IBOutlet var multiSelectioView: UIView?

    var currentView: UIView? {
        didSet {
            oldValue?.isHidden = true
            currentView?.isHidden = false
        }
    }
    
    @IBOutlet var selectedAction: UIButton! {
        didSet {
            if oldValue != nil {
                oldValue.isSelected = false
            }
            selectedAction.isSelected = true
        }
    }
    
    var propertyViewController: PropertyViewController? {
        didSet {
            guard let views = self.views else { return }
            guard let propertyViewController = self.propertyViewController else { return }
            let propertyView = views[2]
            propertyView.addSubview(propertyViewController.view)
            propertyViewController.view.snp.makeConstraints { (make) in
                make.edges.equalTo(propertyView)
            }
            self.addChildViewController(propertyViewController)
        }
    }
    
    var tagPropertiesViewController: TagPropertiesViewController? {
        didSet {
            guard let views = self.views else { return }
            guard let tagPropertiesViewController = self.tagPropertiesViewController else { return }
            let propertyView = views[2]
            propertyView.addSubview(tagPropertiesViewController.view)
            tagPropertiesViewController.view.snp.makeConstraints { (make) in
                make.edges.equalTo(propertyView)
            }
            self.addChildViewController(tagPropertiesViewController)
        }
    }
    
    var _tagWithInfo: TagWithInfo? {
        didSet {
            tagPropertiesViewController?.tagWithInfo = tagWithInfo
            if let tag = tag, let contrainer = contrainer {
                tag.bindView(view: contrainer)
                tag.delegate = self
                tag.resetHistories()
                self.currentChanged(tag: tag)
            }
        }
    }

    var tagWithInfo: TagWithInfo? {
        set {
            if let value = newValue, value.data == nil, let templateId = value.template_id {
                API.shared.getTag(templateId) { (tagWithInfo, error) in
                    if let tagWithInfo = tagWithInfo {
                        self._tagWithInfo = tagWithInfo
                    }
                }
            }
            _tagWithInfo = newValue
        }
        
        get {
            return _tagWithInfo
        }
    }
    var tag: Tag? {
        get {
            return tagWithInfo?.data
        }
        
        set {
            if let tag = newValue {
                if let contrainer = contrainer {
                    contrainer.subviews.forEach({ (view) in
                        view.removeFromSuperview()
                    })
                    tag.bindView(view: contrainer)
                }
                
                tag.delegate = self
                tagWithInfo?.data = tag
            }
        }
    }
    
    static func fromStoryboard () -> EditViewController {
        return UIStoryboard.get("edit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.contrainer?.layer.shadowColor = UIColor.black.cgColor
//        self.contrainer?.layer.shadowOffset = CGSize.zero
//        self.contrainer?.layer.shadowRadius = 5
//        self.contrainer?.layer.shadowOpacity = 0.5
//        self.contrainer?.layer.masksToBounds = false
        self.selectionSwither?.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        self.currentView = views![1]

        self.tagPropertiesViewController = TagPropertiesViewController.fromStoryboard()
        self.propertyViewController = PropertyViewController.fromStoryboard()
    }
    
    @IBAction func toggleSelectionView () {
        if let selectionView = selectionView {
            selectionView.isHidden = !selectionView.isHidden
        }
    }
    
    @IBAction func switchSelection (sender: UIButton) {
        let allowMultiSelections = sender.tag == 1
        tag?.allowMultiSelections = allowMultiSelections
        self.selectionSwither?.isSelected = allowMultiSelections
        self.selectionView?.isHidden = true
    }
    
    @IBAction func forwardHistory () {
        self.tag = tag?.forward()
    }
    
    @IBAction func backwardHistory () {
        self.tag = tag?.backward()
    }
    
    @objc @IBAction func selectView(sender: UIButton) {
        let view = self.views![sender.tag]
        self.currentView = view
        self.selectedAction = sender
    }
    
    @objc @IBAction func handleAddItem(sender: UIButton) {
        guard let itemType = ItemType(tag: sender.tag) else { return }
        if itemType == .image {
            self.changeImage(isLogo: sender.tag == 4)
            return
        }
        let item = itemType.getInstance()
        self.tag?.addItem(item)
    }
    
    @objc @IBAction func showTextItemTextView() {
        if let view = self.textItemTextView {
            self.propertyViewController?.addView(NSLocalizedString("文本输入", comment: "文本输入"), view: view, push: false)
        }
    }
    
    @objc @IBAction func inputTextItemText () {
        if self.propertyViewController?.view.subviews.last == self.textItemTextView {
            self.propertyViewController?.popView()
        }
        
        guard let textItem = self.tag?.currentTextItem else { return }
        let inputViewController = InputViewController.fromStoryboard()
        inputViewController.title = NSLocalizedString("输入文本内容", comment: "输入文本内容")
        inputViewController.inputTextField?.text = textItem.text
        inputViewController.callback = {(text: String) -> Bool in
            textItem.text = text
            textItem.keepHistory()
            return true
        }
        self.navigationController?.pushViewController(
            inputViewController, animated: true)
    }
    
    @objc @IBAction func scanTextItemText () {
        self.propertyViewController?.popView()
        guard let textItem = self.tag?.currentTextItem else { return }
        let viewController = ScanViewController.fromStoryboard()
        viewController.callback = {(text: String) -> Bool in
            textItem.text = text
            textItem.keepHistory()
            return true
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc @IBAction func showTextItemInitNumberView () {
        if let view = self.textItemInitNumberView {
            if let textItem = self.tag?.currentTextItem {
                self.textItemInitNumberLabel?.text = String(format: "%d", textItem.textStep)
                self.propertyViewController?.addView(NSLocalizedString("递增量", comment: "递增量"), view: view, confirmBlock: { () -> Bool in
                    guard let text = self.textItemInitNumberLabel?.text else { return false }
                    guard let value = Int(text) else { return false }
                    textItem.textStep = value
                    textItem.keepHistory()
                    return true
                })
            }
        }
    }
    
    @objc @IBAction func increseInitNumber () {
        guard let text = self.textItemInitNumberLabel?.text else { return }
        guard let value = Int(text) else { return }
        self.textItemInitNumberLabel?.text = String(format: "%02d", value + 1)
    }
    
    @objc @IBAction func decreseInitNumber () {
        guard let text = self.textItemInitNumberLabel?.text else { return }
        guard let value = Int(text) else { return }
        self.textItemInitNumberLabel?.text = String(format: "%02d", value - 1)
    }
    
    @objc @IBAction func inputTextItemInitNumber () {
        guard let textItem = self.tag?.currentTextItem else { return }
        let inputViewController = InputViewController.fromStoryboard()
        inputViewController.title = NSLocalizedString("编辑数字", comment: "编辑数字")
        inputViewController.isNumber = true
        inputViewController.min = 0
        inputViewController.max = 1000
        inputViewController.inputTextField?.text = String(format: "%d", textItem.textStep)
        inputViewController.callback = {(text: String) -> Bool in
            if let value = Int(text) {
                self.textItemInitNumberLabel?.text = String(format: "%02d", value)
                return true
            }
            return true
        }
        self.navigationController?.pushViewController(inputViewController, animated: true)
    }
    
    @objc @IBAction func showItemAngelView() {
        if let view = self.angelView {
            self.syncItemAngel()
            self.propertyViewController?.addView(NSLocalizedString("旋转角度", comment: "旋转角度"), view: view, confirmBlock: { () -> Bool in
                guard let selectedAngelButton = self.angelButtons?.first(where: { (button) -> Bool in
                    return button.isSelected
                }) else { return false }
                guard let angelText = selectedAngelButton.title(for: .normal) else { return false }
                guard let angel = Int(angelText.digital) else { return false }
                guard let item = self.tag?.current else { return false }
                item.angel = angel
                item.keepHistory()
                self.tag?.syncRotate(item: item)
                return true
            })
        }
    }
    
    func syncItemAngel () {
        guard let item = self.tag?.current else { return }
        var isOtherAngel = true
        angelButtons?.forEach({ (button) in
            if button.tag == item.angel/90 {
                button.isSelected = true
                isOtherAngel = false
            } else {
                button.isSelected = false
            }
        })
        if let otherAngelButton = self.otherAngelButton {
            if isOtherAngel {
                otherAngelButton.isSelected = true
                otherAngelButton.setTitle(String(format: "%d°", item.angel), for: .normal)
            } else {
                otherAngelButton.isSelected = false
                otherAngelButton.setTitle(NSLocalizedString("其他", comment: "其他"), for: .normal)
            }
        }
    }
    
    @objc @IBAction func changeItemAngel(sender: UIButton) {
        angelButtons?.forEach({ (button) in
            button.isSelected = button === sender
        })
    }
    
    @objc @IBAction func inputItemAngel () {
        guard let item = self.tag?.current else { return }
        let inputViewController = InputViewController.fromStoryboard()
        inputViewController.title = NSLocalizedString("输入角度", comment: "输入角度")
        inputViewController.isNumber = true
        inputViewController.min = 0
        inputViewController.max = 360
        inputViewController.inputTextField?.text = String(format: "%d", item.angel)
        inputViewController.callback = {(text: String) -> Bool in
            if let angel = Int(text) {
                if let otherAngelButton = self.otherAngelButton {
                    self.changeItemAngel(sender: otherAngelButton)
                    otherAngelButton.setTitle(String(format: "%d°", angel), for: .normal)
                }
                return true
            }
            return true
        }
        self.navigationController?.pushViewController(inputViewController, animated: true)
    }
    
    @objc @IBAction func showItemLocationView () {
        guard let current = self.tag?.current else { return }
        let locationPropertiesViewController = LocationPropertiesViewController.fromStoryboard()
        locationPropertiesViewController.item = current
        self.propertyViewController?.addViewController(
            locationPropertiesViewController, confirmBlock: { () -> Bool in
            locationPropertiesViewController.syncBack()
            return true
        })
    }
    
    @objc @IBAction func showItemFontView () {
        guard let textItem = self.tag?.currentTextItem else { return }
        let fontPropertiesViewController = FontPropertiesViewController.fromStoryboard()
        fontPropertiesViewController.textItem = textItem
        self.propertyViewController?.addViewController(
            fontPropertiesViewController, confirmBlock: { () -> Bool in
            fontPropertiesViewController.syncBack()
            return true
        })
    }
    
    @objc @IBAction func showItemsAlignView () {
        guard let tag = self.tag else { return }
        let viewController = ItemsAlignPropertiesViewController.fromStoryboard()
        viewController.tag = tag
        self.propertyViewController?.addViewController(
            viewController, confirmBlock: { () -> Bool in
                viewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func showItemParaView () {
        guard let textItem = self.tag?.currentTextItem else { return }
        let paraPropertiesViewController = ParaPropertiesViewController.fromStoryboard()
        paraPropertiesViewController.textItem = textItem
        self.propertyViewController?.addViewController(
            paraPropertiesViewController, confirmBlock: { () -> Bool in
            paraPropertiesViewController.syncBack()
            return true
        })
    }
    
    @objc @IBAction func showItemOtherView () {
        guard let item = self.tag?.current else { return }
        let otherPropertiesViewController = OtherPropertiesViewController.fromStoryboard()
        otherPropertiesViewController.item = item
        self.propertyViewController?.addViewController(
            otherPropertiesViewController, confirmBlock: { () -> Bool in
            otherPropertiesViewController.syncBack()
            return true
        })
    }
    
    @objc @IBAction func showExcelView () {
        guard let excel = self.tag?.currentExcel else { return }
        let excelPropertiesViewController = ExcelPropertiesViewController.fromStoryboard()
        excelPropertiesViewController.excel = excel
        self.propertyViewController?.addViewController(
            excelPropertiesViewController, confirmBlock: { () -> Bool in
            excelPropertiesViewController.syncBack()
            return true
        })
    }
    
    @objc @IBAction func showBarcodeView () {
        guard let barcodeItem = self.tag?.current as? BarCodeItem else { return }
        let barcodePropertiesViewController = BarcodePropertiesViewController.fromStoryboard()
        barcodePropertiesViewController.barcode = barcodeItem
        self.propertyViewController?.addViewController(
            barcodePropertiesViewController, confirmBlock: { () -> Bool in
                barcodePropertiesViewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func showQrcodeView () {
        guard let qrcodeItem = self.tag?.current as? QRCodeItem else { return }
        let qrcodePropertiesViewController = QRCodePropertiesViewController.fromStoryboard()
        qrcodePropertiesViewController.qrcode = qrcodeItem
        self.propertyViewController?.addViewController(
            qrcodePropertiesViewController, confirmBlock: { () -> Bool in
                qrcodePropertiesViewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func setSolidLine () {
        guard let lineItem = self.tag?.current as? LineItem else { return }
        lineItem.dash = 0
    }
    
    @objc @IBAction func showLineView () {
        guard let lineItem = self.tag?.current as? LineItem else { return }
        let linePropertiesViewController = LinePropertiesViewController.fromStoryboard()
        linePropertiesViewController.line = lineItem
        self.propertyViewController?.addViewController(
            linePropertiesViewController, confirmBlock: { () -> Bool in
                linePropertiesViewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func changeShape(sender: UIButton) {
        guard let shapeItem = self.tag?.current as? ShapeItem else { return }
        guard let shape = Shape(tag: sender.tag) else { return }
        shapeItem.shape = shape
        shapeItem.keepHistory()
    }

    @objc @IBAction func toggleShapeFill(sender: UIButton) {
        guard let shapeItem = self.tag?.current as? ShapeItem else { return }
        shapeItem.fill = !shapeItem.fill
        shapeItem.keepHistory()
    }
    
    @objc @IBAction func changeShapeBorderWidth () {
        guard let shapeItem = self.tag?.current as? ShapeItem else { return }
        let inputViewController = InputViewController.fromStoryboard()
        inputViewController.title = NSLocalizedString("线条宽度", comment: "线条宽度")
        inputViewController.isNumber = true
        inputViewController.min = 0
        inputViewController.max = 1000
        inputViewController.inputTextField?.text = String(shapeItem.borderWidth)
        inputViewController.callback = {(text: String) -> Bool in
            if let value = Float(text) {
                shapeItem.borderWidth = value
                shapeItem.keepHistory()
            }
            return true
        }
        self.navigationController?.pushViewController(inputViewController, animated: true)
    }
    
    @objc @IBAction func changeTableBorderWidth () {
        guard let tableItem = self.tag?.current as? TableItem else { return }
        let inputViewController = InputViewController.fromStoryboard()
        inputViewController.title = NSLocalizedString("线条宽度", comment: "线条宽度")
        inputViewController.isNumber = true
        inputViewController.min = 0
        inputViewController.max = 1000
        inputViewController.inputTextField?.text = String(tableItem.borderWidth)
        inputViewController.callback = {(text: String) -> Bool in
            if let value = Float(text) {
                tableItem.borderWidth = value
                tableItem.keepHistory()
            }
            return true
        }
        self.navigationController?.pushViewController(inputViewController, animated: true)
    }
    
    @objc @IBAction func changeTableRows (sender: UIButton) {
        guard let tableItem = self.tag?.current as? TableItem else { return }
        let viewController = TablePropertiesViewController.fromStoryboard()
        viewController.isRow = true
        viewController.tableItem = tableItem
        self.propertyViewController?.addViewController(
            viewController, confirmBlock: { () -> Bool in
                viewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func changeTableColumns (sender: UIButton) {
        guard let tableItem = self.tag?.current as? TableItem else { return }
        let viewController = TablePropertiesViewController.fromStoryboard()
        viewController.isRow = false
        viewController.tableItem = tableItem
        self.propertyViewController?.addViewController(
            viewController, confirmBlock: { () -> Bool in
                viewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func showTimeView () {
        guard let timeItem = self.tag?.current as? TimeItem else { return }
        let timePropertiesViewController = TimePropertiesViewController.fromStoryboard()
        timePropertiesViewController.time = timeItem
        self.propertyViewController?.addViewController(
            timePropertiesViewController, confirmBlock: { () -> Bool in
                timePropertiesViewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func changeImage () {
        guard let imageItem = self.tag?.current as? ImageItem else { return }
        if let _ = imageItem as? QRCodeItem {
            return
        }
        if let _ = imageItem as? BarCodeItem {
            return
        }
        self.changeImage(isLogo: imageItem.isLogo)
    }
    
    func changeImage(isLogo: Bool) {
        if isLogo {
            let viewController = IconsViewController.fromStoryboard()
            viewController.delegate = self
            self.navigationController?.pushViewController(
                viewController, animated: true)
        } else {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @objc @IBAction func toggleTile () {
        guard let imageItem = self.tag?.current as? ImageItem else { return }
        let simple = SimpleListViewController.fromStoryboard()
        simple.title = NSLocalizedString("平铺", comment: "平铺")
        simple.texts = [NSLocalizedString("是", comment: "是"), NSLocalizedString("否", comment: "否")]
        simple.text = imageItem.tile ? NSLocalizedString("是", comment: "是") : NSLocalizedString("否", comment: "否")
        self.propertyViewController?.addViewController(simple, confirmBlock: { () -> Bool in
            imageItem.tile = simple.text == NSLocalizedString("是", comment: "是")
            imageItem.keepHistory()
            return true
        })
    }
    
    @objc @IBAction func showImageModeView () {
        guard let imageItem = self.tag?.current as? ImageItem else { return }
        let imageModePropertiesViewController = ImageModePropertiesViewController.fromStoryboard()
        imageModePropertiesViewController.image = imageItem
        self.propertyViewController?.addViewController(
            imageModePropertiesViewController, confirmBlock: { () -> Bool in
                imageModePropertiesViewController.syncBack()
                return true
        })
    }
    
    @objc @IBAction func print () {
        PrintSettingViewController.print(tag: tagWithInfo, from: self)
    }
    
    @objc @IBAction func giveup () {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc @IBAction func cancel () {
        self.existView?.isHidden = true
    }
    
    @objc @IBAction func exist () {
        self.existView?.isHidden = false
    }
    
    @objc @IBAction func new () {
        let new = NewViewController.fromStoryboard()
        self.navigationController?.pushViewController(new, animated: true)
    }
    
    @objc @IBAction func save (sender: UIButton) {
        guard let tagWithInfo = tagWithInfo else { return }
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在保存", comment: "正在保存"))
        
        if let tag = tagWithInfo.data {
            let render = RenderView()
            render.scale = UIScreen.main.scale
            render.scaleWhenRender = Float(UIScreen.main.bounds.width)/tag.width
            render.render(tag, view: self.view) { (image, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "\(error)")
                    return
                }
                guard let image = image else { return }
                API.shared.upload(image, callback: { (key, error) in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "\(error)")
                        return
                    }
                    tagWithInfo.preview = key ?? ""
                    self.saveTag(dismiss: sender.tag > 0)
                })
            }
        } else {
            saveTag(dismiss: sender.tag > 0)
        }
    }
    
    func saveTag (dismiss: Bool=false) {
        guard let tagWithInfo = tagWithInfo else { return }
        API.shared.updateTag(tagWithInfo) { (tag, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("保存成功", comment: "保存成功"))
            if (dismiss) {
                self.navigationController?.popViewController(
                    animated: true)
            }
        }
    }
    
    @objc @IBAction func saveAs () {
        guard let tagWithInfo = tagWithInfo else { return }
        let alert = UIAlertController(title: NSLocalizedString("另存为新标签", comment: "另存为新标签"), message: NSLocalizedString("新标签名不能为空", comment: "新标签名不能为空"), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = tagWithInfo.name + "-1"
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: "取消"), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "确定"), style: .default) { (action) in
            let textField = alert.textFields![0]
            let cloned = tagWithInfo.clone()
            cloned.name = textField.text ?? ""
            
            let edit = EditViewController.fromStoryboard()
            edit.tagWithInfo = cloned
            self.navigationController?.pushViewController(edit, animated: true)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc @IBAction func copyItem () {
        guard let tag = tag else { return }
        guard let current = tag.current else { return }
        let cloned = current.clone()
        tag.addItem(cloned)
    }
    
    @objc @IBAction func sendBack () {
        guard let tag = tag else { return }
        guard let current = tag.current else { return }
        tag.moveItem(current, toFront: false)
    }
    
    @objc @IBAction func sendFront () {
        guard let tag = tag else { return }
        guard let current = tag.current else { return }
        tag.moveItem(current, toFront: true)
    }
    
    @objc @IBAction func deleteItem () {
        guard let tag = tag else { return }
        guard let current = tag.current else { return }
        tag.removeItem(current)
    }
    
    @objc @IBAction func open () {
        let viewController = CategoriesViewController.fromStoryboard()
        self.navigationController?.pushViewController(
            viewController, animated: true)
    }
    
    @objc @IBAction func lock () {
        guard let tag = tagWithInfo?.data else { return }
        tag.locked = !tag.locked
        
        SVProgressHUD.showInfo(withStatus: tag.locked ? NSLocalizedString("已锁定", comment: "已锁定") : NSLocalizedString("已解锁", comment: "已解锁"))
    }
}

extension EditViewController: TagDelegate {
    func historyChanged(tag: Tag) {
        backwardHistoryButton?.isEnabled = tag.canBackward
        forwardHistoryButton?.isEnabled = tag.canForward
    }
    
    func itemDoubleTaped(tag: Tag, item: Item) {
        if let _ = item.textItem {
            self.inputTextItemText()
        }
    }
    
    func currentChanged(tag: Tag) {
        let currents = tag.currents
        if currents.count > 1 {
            tagPropertiesViewController?.view.isHidden = true
            propertyViewController?.view.isHidden = false
            
            if let multiSelectioView = self.multiSelectioView {
                propertyViewController?.presentView("", view: multiSelectioView)
            }
            return
        }
        if let item = tag.current {
            tagPropertiesViewController?.view.isHidden = true
            propertyViewController?.view.isHidden = false
            if let _ = item as? TimeItem, let timeItemView = self.timeItemView {
                propertyViewController?.presentView("", view: timeItemView)
            } else if let _ = item as? TextItem, let textItemView = self.textItemView {
                propertyViewController?.presentView("", view: textItemView)
            } else if let _ = item as? BarCodeItem, let barCodeView = self.barCodeItemView {
                propertyViewController?.presentView("", view: barCodeView)
            } else if let _ = item as? QRCodeItem, let qrcodeItemView = self.qrcodeItemView {
                propertyViewController?.presentView("", view: qrcodeItemView)
            } else if let _ = item as? LineItem, let lineItemView = self.lineItemView {
                propertyViewController?.presentView("", view: lineItemView)
            } else if let _ = item as? ShapeItem, let shapeItemView = self.shapeItemView {
                propertyViewController?.presentView("", view: shapeItemView)
            } else if let _ = item as? ImageItem, let imageItemView = self.imageItemView {
                propertyViewController?.presentView("", view: imageItemView)
            } else if let tableItem = item as? TableItem, let tableItemView = self.tableItemView {
                if let _ = tableItem.text, let textItemView = self.textItemView {
                    propertyViewController?.presentView("", view: textItemView)
                } else {
                    propertyViewController?.presentView("", view: tableItemView)
                }
            }
        } else {
            tagPropertiesViewController?.view.isHidden = false
            propertyViewController?.view.isHidden = true
        }
    }
}

extension EditViewController: IconsViewControllerDelegate {
    
    func iconsViewController(_ controller: IconsViewController, selectedLogo: Logo) {
        var imageItem: ImageItem
        if let currentImageItem = self.tag?.current as? ImageItem, currentImageItem.type == .image {
            imageItem = currentImageItem
        } else {
            imageItem = ItemType.image.getInstance() as! ImageItem
            imageItem.isLogo = true
            self.tag?.addItem(imageItem)
        }
        imageItem.image = selectedLogo.key
    }
}

extension EditViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        var imageItem: ImageItem
        if let currentImageItem = self.tag?.current as? ImageItem, currentImageItem.type == .image {
            imageItem = currentImageItem
        } else {
            imageItem = ItemType.image.getInstance() as! ImageItem
            self.tag?.addItem(imageItem)
        }
        
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在上传图片 ...", comment: "正在上传图片 ..."))
        imageItem._image = image
        API.shared.upload(image) { (imageUrl, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("上传图片成功", comment: "上传图片成功"))
            guard let imageUrl = imageUrl else { return }
            imageItem.image = imageUrl
            imageItem.updateConstraint()
            imageItem.keepHistory()
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
