//
//  LoginViewController.swift
//  bee
//
//  Created by Herb on 2018/8/29.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var observer: Any?
    var oauth: TencentOAuth!

    @IBOutlet var otherLoginMethodsView: UIView!
    @IBOutlet var wechatButton: UIButton!
    @IBOutlet var qqButton: UIButton!
    
    @IBOutlet var telephoneTextField: UITextField!
    @IBOutlet var codeTextField: UITextField!
    @IBOutlet var sendCodeButton: UIButton!
    
    var timer: Timer? = nil
    var countdown = 0 {
        didSet {
            if countdown > 0 {
                self.sendCodeButton.setTitle("\(countdown)", for: .normal)
            } else {
                timer?.invalidate()
                timer = nil
                self.sendCodeButton.setTitle(NSLocalizedString("发送验证码", comment: "发送验证码"), for: .normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("SendAuthResp"), object: nil, queue: OperationQueue.main) { (notification) in
            guard let code = notification.userInfo?["code"] as? String else { return }
            SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在登录 ...", comment: "正在登录 ..."))
            API.shared.loginByWechat(code: code, callback: { (user, error) in
                self.afterLogin(error: error)
            })
        }
        
        oauth = TencentOAuth(appId: "1107202578", andDelegate: self)
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wechatButton.isHidden = !WXApi.isWXAppInstalled()
        self.qqButton.isHidden = !QQApiInterface.isQQInstalled()
        
        if self.wechatButton.isHidden, self.qqButton.isHidden {
            self.otherLoginMethodsView.isHidden = true
        }
    }
    
    @IBAction func onSendCode (sender: UIButton) {
        guard let phone = self.telephoneTextField.text, phone.count == 11 else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("请输入正确的手机号码", comment: "请输入正确的手机号码"))
            return
        }
        if countdown > 0 {
            return
        }
        API.shared.sendCode(phone) { (_, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: String(format: "%@", error.localizedDescription))
                return
            }
            
            self.countdown = 120
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.countdown -= 1
            })
        }
    }
    
    func afterLogin (error: Error?) {
        if let _ = error {
            SVProgressHUD.showError(withStatus: NSLocalizedString("登录失败", comment: "登录失败"))
            return
        }
        SVProgressHUD.showSuccess(withStatus: NSLocalizedString("登录成功", comment: "登录成功"))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onLogin (sender: UIButton) {
        guard let phone = self.telephoneTextField.text, phone.count == 11 else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("请输入正确的手机号码", comment: "请输入正确的手机号码"))
            return
        }
        guard let code = self.codeTextField.text, !code.isEmpty else {
            SVProgressHUD.showError(withStatus: NSLocalizedString("请输入验证码", comment: "请输入验证码"))
            return
        }
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在登录 ...", comment: "正在登录 ..."))
        API.shared.login(phone, code: code) { (user, error) in
            self.afterLogin(error: error)
        }
    }
    
    @IBAction func onWechatLogin (sender: UIButton) {
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        WXApi.send(req)
    }
    
    @IBAction func onQQLogin (sender: UIButton) {
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在登录 ...", comment: "正在登录 ..."))
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        oauth?.authorize(permissions, inSafari: false)
    }
}

extension LoginViewController: TencentSessionDelegate {
    func tencentDidLogin() {
        oauth.getUserInfo()
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
    }
    
    func tencentDidNotNetWork() {
    }
    
    func getUserInfoResponse(_ response: APIResponse) {
        let user = User()
        user.openid = oauth.openId
        user.nickname = response.jsonResponse["nickname"] as? String ?? ""
        user.avatar = response.jsonResponse["figureurl"] as? String ?? ""
        user.city = response.jsonResponse["city"] as? String ?? ""
        user.province = response.jsonResponse["province"] as? String ?? ""
        user.gender = (response.jsonResponse["gender"] as? String ?? "") == "男" ? .male : .female
        API.shared.login(user) { (user, error) in
            self.afterLogin(error: error)
        }
    }
}
