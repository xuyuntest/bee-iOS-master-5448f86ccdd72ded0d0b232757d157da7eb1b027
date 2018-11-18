//
//  ScanViewController.swift
//  bee
//
//  Created by Herb on 2018/9/21.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes_Swift

class ScanViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var videoPreview: UIView!
    private var videoLayer: CALayer!
    
    var codeReader: CodeReader = AVCodeReader()
    var callback: ((String) -> Bool)?
    
    static func fromStoryboard () -> ScanViewController {
        return UIStoryboard.get("scan")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            flashButton.isSelected = videoDevice.isTorchActive
        }
        
        videoLayer = codeReader.videoPreview
        videoPreview.layer.addSublayer(videoLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoLayer.frame = videoPreview.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeReader.startReading { [weak self] (code) in
            self?.scanedCode(code)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        codeReader.stopReading()
    }
    
    func scanedCode(_ code: String) {
        if let callback = self.callback, callback(code) {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss()
            }
            SVProgressHUD.showSuccess(withStatus: NSLocalizedString("识别成功", comment: "识别成功"))
        }
    }
    
    @IBAction func readImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        picker.dismiss(animated: true, completion: nil)
        
        SVProgressHUD.showProgress(-1, status: NSLocalizedString("正在识别图像 ...", comment: "正在识别图像 ..."))
        DispatchQueue.global(qos: .userInteractive).async {
            guard let cgImage = image.cgImage else { return }
            let ciImage = CIImage(cgImage: cgImage)
            // 尝试 CI
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(options: nil), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            let features = detector?.features(in: ciImage)
            if let feature = features?.first as? CIQRCodeFeature, let code = feature.messageString {
                DispatchQueue.main.async {
                    self.scanedCode(code)
                }
                return
            }
            
            let source = ZXCGImageLuminanceSource(cgImage: cgImage)
            if let binary = ZXHybridBinarizer.binarizer(with: source) as? ZXBinarizer {
                let bitmap = ZXBinaryBitmap.binaryBitmap(with: binary) as! ZXBinaryBitmap
                let hints = ZXDecodeHints.hints() as! ZXDecodeHints
                hints.tryHarder = true
                let reader = ZXMultiFormatReader.reader() as! ZXReader
                let multi = ZXGenericMultipleBarcodeReader(delegate: reader)
                do {
                    let results = try multi!.decodeMultiple(bitmap, hints: hints)
                    let result = results.first as? ZXResult
                    if let code = result?.text, !code.isEmpty {
                        DispatchQueue.main.async {
                            self.scanedCode(code)
                        }
                        return
                    }
                } catch {
                }
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.showError(withStatus: NSLocalizedString("没有找到一维码或二维码", comment: "没有找到一维码或二维码"))
            }
        }
    }
    
    @IBAction func toggleFlash(sender: UIButton) {
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                return
        }
        if videoDevice.hasTorch {
            do {
                try videoDevice.lockForConfiguration()
            } catch {
                return
            }
            if videoDevice.isTorchActive {
                videoDevice.torchMode = .off
            } else {
                videoDevice.torchMode = .on
            }
            sender.isSelected = videoDevice.torchMode == .on
            videoDevice.unlockForConfiguration()
        }
    }
}
