//
//  ExcelPreviewViewController.swift
//  bee
//
//  Created by Herb on 2018/8/26.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import QuickLook

class ExcelPreviewViewController: QuickLook.QLPreviewController {
    
    var url: URL?
    
    override func viewDidLoad() {
        self.dataSource = self
    }
}

extension ExcelPreviewViewController: QuickLook.QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return url != nil ? 1 : 0
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return NSURL(fileURLWithPath: url!.path)
    }
}
