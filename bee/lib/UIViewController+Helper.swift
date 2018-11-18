//
//  UIViewController+Extension.swift
//  rili
//
//  Created by Herb on 2018/4/16.
//  Copyright © 2018年 fenzotech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func pop () {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func endEditing () {
        self.view.endEditing(false)
    }
    
}
