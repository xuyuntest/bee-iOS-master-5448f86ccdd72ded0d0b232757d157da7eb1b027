//
//  TagPropertiesViewController.swift
//  bee
//
//  Created by Herb on 2018/8/13.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TagPropertiesViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var widthLabel: UILabel?
    @IBOutlet weak var heightLabel: UILabel?
    @IBOutlet weak var gapLabel: UILabel?
    @IBOutlet weak var vericalOffsetLabel: UILabel?
    @IBOutlet weak var horizontalOffsetLabel: UILabel?
    @IBOutlet weak var tailLabel: UILabel?
    
    @IBOutlet weak var concentrationLabel: UILabel?
    @IBOutlet weak var speedLabel: UILabel?
    
    @IBOutlet var angelButtons: [UIButton]?
    @IBOutlet var intervalButtons: [UIButton]?
    @IBOutlet var tailButtons: [UIButton]?

    @IBOutlet weak var flagButton: UIButton?
    @IBOutlet weak var mirrorButton: UIButton?
    @IBOutlet weak var lockButton: UIButton?

    @IBOutlet weak var clearBackgroundButton: UIButton?
    
    var isNew: Bool = false
    
    static func fromStoryboard () -> TagPropertiesViewController {
        return UIStoryboard.get("edit", identifier: "TagPropertiesView")
    }
    
    var tagWithInfo: TagWithInfo? {
        didSet {
            guard let _ = tag else { return }
            sync()
        }
    }
    var tag: Tag? {
        return tagWithInfo?.data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func sync () {
        syncName()
        syncWidth()
        syncHeight()
        syncGap()
        syncFlag()
        syncMirror()
        syncTail()
        syncHorizontailOffset()
        syncVericalOffset()
        syncLocked()
        syncPrintConcentration()
        syncSpeed()
        syncBackground()
        syncAngel()
        syncInterval()
        syncTailDirection()
    }
    
    func syncAngel () {
        guard let tag = tag else { return }
        angelButtons?.forEach({ (button) in
            button.isSelected = button.tag == tag.angel/90
        })
    }
    
    func syncInterval () {
        guard let tag = tag else { return }
        intervalButtons?.forEach({ (button) in
            button.isSelected = PageIntervalType(tag: button.tag) == tag.pageIntervalType
        })
    }
    
    func syncTailDirection () {
        guard let tag = tag else { return }
        tailButtons?.forEach({ (button) in
           button.isSelected = TagTailDirection(tag: button.tag) == tag.tailDirection
        })
    }
    
    func syncName () {
        nameLabel?.text = tagWithInfo?.name ?? ""
    }
    
    func syncWidth () {
        widthLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.width ?? 0).shortStr)
    }
    
    func syncHeight () {
        heightLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.height ?? 0).shortStr)
    }
    
    func syncGap () {
        gapLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.gap ?? 0).shortStr)
    }
    
    func syncFlag () {
        flagButton?.isSelected = tag?.flag ?? false
    }
    
    func syncMirror () {
        mirrorButton?.isSelected = tag?.mirror ?? false
    }
    
    func syncTail () {
        tailLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.tailLength ?? 0).shortStr)
    }
    
    func syncHorizontailOffset () {
        horizontalOffsetLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.printHorizontalOffset ?? 0).shortStr)
    }
    
    func syncVericalOffset () {
        vericalOffsetLabel?.text = String(format: NSLocalizedString("%@毫米", comment: "%@毫米"), (tag?.printVericalOffset ?? 0).shortStr)
    }
    
    func syncLocked () {
        lockButton?.isSelected = tag?.locked ?? false
    }
    
    func syncPrintConcentration () {
        concentrationLabel?.text = (tag?.printConcentration ?? 1).shortStr
    }
    
    func syncSpeed () {
        speedLabel?.text = (tag?.printSpeed ?? 1).shortStr
    }
    
    func syncBackground() {
        clearBackgroundButton?.isEnabled = (tag?.background ?? "").count > 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew, indexPath.row > 4  {
            return 0
        }
        return tableView.rowHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if indexPath.row == 0 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑名称", comment: "编辑名称")
            inputViewController.max = 20
            inputViewController.inputTextField?.text = tagWithInfo?.name
            inputViewController.callback = {(text: String) -> Bool in
                self.tagWithInfo?.name = text
                self.syncName()
                return true
            }
            viewController = inputViewController
        } else if indexPath.row == 1 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑高度", comment: "编辑高度")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.height ?? 0).shortStr
            inputViewController.min = 10
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let height = Float(text) {
                    self.tag?.height = height
                    self.syncHeight()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 2 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑宽度", comment: "编辑宽度")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.width ?? 0).shortStr
            inputViewController.min = 10
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let width = Float(text) {
                    self.tag?.width = width
                    self.syncWidth()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 5 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑间隔", comment: "编辑间隔")
            inputViewController.isNumber = true
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.gap ?? 0).shortStr
            inputViewController.min = 0
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let gap = Float(text) {
                    self.tag?.gap = gap
                    self.syncGap()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 6 {
            if let tag = tag {
                tag.flag = !tag.flag
            }
            syncFlag()
        } else if indexPath.row == 7 {
            if let tag = tag {
                tag.mirror = !tag.mirror
            }
            syncMirror()
        } else if indexPath.row == 9 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑尾巴长度", comment: "编辑尾巴长度")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.tailLength ?? 0).shortStr
            inputViewController.min = 0
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let value = Float(text) {
                    self.tag?.tailLength = value
                    self.syncTail()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 13 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑水平方向偏移", comment: "编辑水平方向偏移")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.printHorizontalOffset ?? 0).shortStr
            inputViewController.min = 0
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let offset = Float(text) {
                    self.tag?.printHorizontalOffset = offset
                    self.syncHorizontailOffset()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 14 {
            let inputViewController = InputViewController.fromStoryboard()
            inputViewController.title = NSLocalizedString("编辑垂直方向偏移", comment: "编辑垂直方向偏移")
            inputViewController.isNumber = true
            inputViewController.inputTextField?.text = (tag?.printVericalOffset ?? 0).shortStr
            inputViewController.min = 0
            inputViewController.max = 1000
            inputViewController.callback = {(text: String) -> Bool in
                if let offset = Float(text) {
                    self.tag?.printVericalOffset = offset
                    self.syncVericalOffset()
                    return true
                }
                return false
            }
            viewController = inputViewController
        } else if indexPath.row == 15 {
            if let tag = tag {
                tag.locked = !tag.locked
            }
            syncLocked()
        }
        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc @IBAction func changeAngel(sender: UIButton) {
        tag?.angel = sender.tag * 90
        syncAngel()
    }
    
    @objc @IBAction func changeInterval(sender: UIButton) {
        if let value = PageIntervalType(tag: sender.tag) {
            tag?.pageIntervalType = value
            syncInterval()
        }
    }
    
    @objc @IBAction func changeTail(sender: UIButton) {
        if let value = TagTailDirection(tag: sender.tag) {
            tag?.tailDirection = value
            syncTailDirection()
        }
    }
    
    @objc @IBAction func clearBackground() {
        if let tag = tag, tag.locked {
            SVProgressHUD.showError(withStatus: NSLocalizedString("解锁后才能修改背景", comment: "解锁后才能修改背景"))
            return
        }
        tag?.background = ""
        syncBackground()
    }
    
    @objc @IBAction func increaseConcentration(sender: UIButton) {
        let printConcentration = (tag?.printConcentration ?? 0) + 1
        if printConcentration > 16 {
            return
        }
        tag?.printConcentration = printConcentration
        syncPrintConcentration()
    }
    
    @objc @IBAction func decreaseConcentration(sender: UIButton) {
        let printConcentration = (tag?.printConcentration ?? 0) - 1
        if printConcentration <= 0 {
            return
        }
        tag?.printConcentration = printConcentration
        syncPrintConcentration()
    }
    
    @objc @IBAction func increaseSpeed(sender: UIButton) {
        let printSpeed = (tag?.printSpeed ?? 0) + 1
        if printSpeed > 2 {
            return
        }
        tag?.printSpeed = printSpeed
        syncSpeed()
    }
    
    @objc @IBAction func decreaseSpeed(sender: UIButton) {
        let printSpeed = (tag?.printSpeed ?? 0) - 1
        if printSpeed < 0 {
            return
        }
        tag?.printSpeed = printSpeed
        syncSpeed()
    }
    
    @objc @IBAction func changeBackground () {
        if let tag = tag, tag.locked {
            SVProgressHUD.showError(withStatus: NSLocalizedString("解锁后才能修改背景", comment: "解锁后才能修改背景"))
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
}


extension TagPropertiesViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在上传背景 ...", comment: "正在上传背景 ..."))
        API.shared.upload(image) { (imageUrl, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "\(error)")
                return
            }
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("上传背景成功", comment: "上传背景成功"))
            guard let imageUrl = imageUrl else { return }
            self.tag?.backgroundView?.image = image
            self.tag?.background = imageUrl
            picker.dismiss(animated: true, completion: nil)
            
            self.syncBackground()
        }
    }
}
