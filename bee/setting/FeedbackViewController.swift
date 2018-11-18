//
//  FeedbackViewController.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    @objc @IBAction func submit () {
        API.shared.sendFeedback(textView.text) { (response, error) in
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("反馈成功", comment: "反馈成功"))
            self.navigationController?.popViewController(
                animated: true)
        }
    }
}
