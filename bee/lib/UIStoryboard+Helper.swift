//
//  UIStoryboard+Helper.swift
//  bee
//
//  Created by Herb on 2018/9/2.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import Foundation

extension UIStoryboard {
    
    static func get<T>(_ name: String = "", identifier: String = "", load: Bool = true) -> T where T: UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        let viewController: UIViewController!
        if identifier.isEmpty {
            viewController = storyboard.instantiateInitialViewController()
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        }
        if (load) {
            viewController.loadViewIfNeeded()
        }
        return viewController as! T
    }
}
