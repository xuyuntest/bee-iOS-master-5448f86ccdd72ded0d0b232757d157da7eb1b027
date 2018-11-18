//
//  AppDelegate.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        WXApi.registerApp("wx24c48fd968439445")
        FontCacher.shared.registerAll()
        self.setupUI()
        return true
    }
    
    func setupUI () {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        UINavigationBar.appearance().tintColor = UIColor("#1a1a1a")
//        UINavigationBar.appearance().barStyle = UIBarStyle.default
//        UINavigationBar.appearance().barTintColor = UIColor("#FABE00")
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor("#1a1a1a")]
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func handleURL(_ url: URL) -> Bool {
        if WXApi.handleOpen(url, delegate: self) {
            return true
        }
        if TencentOAuth.canHandleOpen(url), TencentOAuth.handleOpen(url) {
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return handleURL(url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleURL(url)
    }
}


extension AppDelegate: WXApiDelegate {
    
    func onReq(_ req: BaseReq) {
    }
    
    func onResp(_ resp: BaseResp) {
        if let resp = resp as? SendAuthResp {
            if resp.errCode == 0 {
                NotificationCenter.default.post(name: Notification.Name("SendAuthResp"), object: self, userInfo: ["code": resp.code])
            } else if resp.errCode == -4 {
                SVProgressHUD.showError(withStatus: NSLocalizedString("用户拒绝", comment: "用户拒绝"))
            } else if resp.errCode == -2 {
                SVProgressHUD.showError(withStatus: NSLocalizedString("用户取消", comment: "用户取消"))
            }
        }
    }
}
