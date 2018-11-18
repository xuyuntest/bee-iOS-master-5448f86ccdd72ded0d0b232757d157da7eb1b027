//
//  UIImage+Encoder.swift
//  bee
//
//  Created by Herb on 2018/8/1.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import RSBarcodes_Swift
import AVFoundation

enum Encoder: String, Codable {
    case code128
    case code39
    case itf25
    case ean13
    case ean8
    case code39Mod43
    case upce
    case isbn
    case aztec
    case code93
    case ecode39
    case itf14
//    case matrix25
    case dataMatrix
    case qrcode
    
    static var barcodes = [
        Encoder.code128,
        Encoder.code39,
        Encoder.itf25,
        Encoder.ean13,
        Encoder.ean8,
        Encoder.code39Mod43,
        Encoder.upce,
        Encoder.isbn,
        Encoder.aztec,
        Encoder.code93,
        Encoder.ecode39,
        Encoder.itf14,
//        Encoder.matrix25,
        Encoder.dataMatrix,
        Encoder.qrcode]
    
    init?(label: String) {
        switch label {
        case "CODE-128":
            self = .code128
        case "CODE-39":
            self = .code39
        case "ITF-25":
            self = .itf25
        case "EAN-13":
            self = .ean13
        case "EAN-8":
            self = .ean8
        case "CODE-39-MOD-43":
            self = .code39Mod43
        case "UPC-E":
            self = .upce
        case "ISBN":
            self = .isbn
        case "AZTEC":
            self = .aztec
        case "CODE-93":
            self = .code93
        case "ECODE-39":
            self = .ecode39
        case "ITF-14":
            self = .itf14
//        case "MATRIX-25":
//            self = .matrix25
        case "Data-Matrix":
            self = .dataMatrix
        case "QRCode":
            self = .qrcode
        default:
            return nil
        }
    }

    var type: String? {
        switch self {
        case .code128:
            return AVMetadataObject.ObjectType.code128.rawValue
        case .code39:
            return AVMetadataObject.ObjectType.code39.rawValue
        case .itf25:
            return AVMetadataObject.ObjectType.interleaved2of5.rawValue
        case .ean13:
            return AVMetadataObject.ObjectType.ean13.rawValue
        case .ean8:
            return AVMetadataObject.ObjectType.ean8.rawValue
        case .upce:
            return AVMetadataObject.ObjectType.upce.rawValue
        case .isbn:
            return RSBarcodesTypeISBN13Code
        case .code93:
            return AVMetadataObject.ObjectType.code93.rawValue
        case .ecode39:
            return RSBarcodesTypeExtendedCode39Code
        case .itf14:
            return AVMetadataObject.ObjectType.itf14.rawValue
//        case .matrix25:
//            return AVMetadataObject.ObjectType.dataMatrix.rawValue
        case .qrcode:
            return AVMetadataObject.ObjectType.qr.rawValue
        case .aztec:
            return AVMetadataObject.ObjectType.aztec.rawValue
        case .code39Mod43:
            return AVMetadataObject.ObjectType.code39Mod43.rawValue
        case .dataMatrix:
            return AVMetadataObject.ObjectType.dataMatrix.rawValue
        }
    }
    
    var label: String {
        switch self {
        case .code128:
            return "CODE-128"
        case .code39:
            return "CODE-39"
        case .itf25:
            return "ITF-25"
        case .ean13:
            return "EAN-13"
        case .ean8:
            return "EAN-8"
        case .code39Mod43:
            return "CODE-39-MOD-43"
        case .upce:
            return "UPC-E"
        case .isbn:
            return "ISBN"
        case .aztec:
            return "AZTEC"
        case .code93:
            return "CODE-93"
        case .ecode39:
            return "ECODE-39"
        case .itf14:
            return "ITF-14"
//        case .matrix25:
//            return "MATRIX-25"
        case .dataMatrix:
            return "Data-Matrix"
        case .qrcode:
            return "QRCode"
        }
    }
}

extension UIImage {
    
    static func toBarcode(string: String, encoder: Encoder, inputCorrectionLevel: InputCorrectionLevel) -> UIImage? {
        if let type = encoder.type {
            let input = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? string
            let shared = RSUnifiedCodeGenerator.shared
            shared.fillColor = UIColor.clear
            let image = shared.generateCode(input, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: type)
            return image
        }
        return nil
    }
}
