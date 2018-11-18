//
//  InputViewController.swift
//  bee
//
//  Created by Herb on 2018/8/14.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {
    
    @IBOutlet public weak var inputTextField: UITextField?
    @IBOutlet weak var placeHolderLabel: UILabel?
    
    var callback: ((String) -> Bool)?
    
    public var min: Int? {
        didSet {
            updatePlaceHolder()
        }
    }
    public var max: Int? {
        didSet {
            updatePlaceHolder()
        }
    }
    public var unit: String = "" {
        didSet {
            updatePlaceHolder()
        }
    }
    public var isNumber: Bool = false
    
    static func fromStoryboard() -> InputViewController {
        return UIStoryboard.get("edit", identifier: "InputView")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputTextField?.becomeFirstResponder()
    }
    
    func updatePlaceHolder() {
        if let min = self.min, let max = self.max {
            if self.isNumber {
                inputTextField?.keyboardType = UIKeyboardType.numberPad
            }
            self.placeHolderLabel?.text = String(format:"%d-%d%@", min, max, self.unit)
        } else {
            inputTextField?.keyboardType = UIKeyboardType.default
        }
    }
    
    @objc @IBAction func save(sender: UIButton) {
        let text = inputTextField?.text ?? ""
        if self.isNumber {
            if let value = Int(text) {
                if let max = self.max, value > max {
                    SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("请输入小于等于%d的数值", comment: "请输入小于等于%d的数值"), max))
                    return
                }
                if let min = self.min, value < min {
                    SVProgressHUD.showError(withStatus: String(format: NSLocalizedString("请输入大于等于%d的数值", comment: "请输入大于等于%d的数值"), min))
                    return
                }
            } else {
                SVProgressHUD.showError(withStatus: NSLocalizedString("请输入数值", comment: "请输入数值"))
                return
            }
        } else {
            if let max = self.max, text.count > max {
                SVProgressHUD.showError(withStatus: NSLocalizedString("输入字符过长", comment: "输入字符过长"))
                return
            }
            if let min = self.min, text.count < min {
                SVProgressHUD.showError(withStatus: NSLocalizedString("输入字符过短", comment: "输入字符过短"))
                return
            }
        }
        if callback?(inputTextField?.text ?? "") ?? false {
            if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 0 {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension InputViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
