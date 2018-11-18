//
//  AVCodeReader.swift
//  bee
//
//  Created by Herb on 2018/9/21.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import AVFoundation

protocol CodeReader {
    func startReading(completion: @escaping (String) -> Void)
    func stopReading()
    var videoPreview: CALayer {get}
}

class AVCodeReader: NSObject {
    fileprivate(set) var videoPreview = CALayer()
    
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var didRead: ((String) -> Void)?
    
    override init() {
        super.init()
        
        //Make sure the device can handle video
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video),
            let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                return
        }
        captureSession = AVCaptureSession()
        
        //input
        captureSession?.addInput(deviceInput)
        
        //output
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [
            .upce, .code39, .code39Mod43, .ean13,
            .ean8, .code93, .code128, .pdf417,
            .qr, .aztec, .interleaved2of5, .itf14, .dataMatrix]
        
        //preview
        let captureVideoPreview = AVCaptureVideoPreviewLayer(session: captureSession!)
        captureVideoPreview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreview = captureVideoPreview
    }
}

extension AVCodeReader: AVCaptureMetadataOutputObjectsDelegate {
     public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = readableCode.stringValue else {
                return
        }
        
        //Vibrate the phone
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        stopReading()
        
        didRead?(code)
    }
}

extension AVCodeReader: CodeReader {
    func startReading(completion: @escaping (String) -> Void) {
        self.didRead = completion
        captureSession?.startRunning()
    }
    func stopReading() {
        captureSession?.stopRunning()
    }
}
