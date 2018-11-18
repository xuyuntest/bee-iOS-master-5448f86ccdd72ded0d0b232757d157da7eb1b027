//
//  TextItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

protocol TextItemProtocol: class {
    func onTextChanged(_ text: String, textItem: TextItem)
}

class TextItem: Item {
    weak var delegate: TextItemProtocol? = nil
    
    var excel = Excel()
    
    var lineSpacing: Float = 0 {
        didSet {
            updateAttributedText()
        }
    }
    var spacing: Float = 0 {
        didSet {
            updateAttributedText()
        }
    }

    var wordWrap: Bool = true {
        didSet {
            updateWordWrap()
        }
    }

    var font: String = "" {
        didSet {
            self.updateFont()
        }
    }
    var fontSize: Float = 2 {
        didSet {
            self.updateFont()
        }
    }
    var bold: Bool = false {
        didSet {
            self.updateFont()
        }
    }
    var italic: Bool = false {
        didSet {
            self.updateFont()
        }
    }
    var underline: Bool = false {
        didSet {
            self.updateAttributedText()
        }
    }
    var strike: Bool = false {
        didSet {
            self.updateAttributedText()
        }
    }
    var watermark: Bool = false
    var align: ItemAlign = .left {
        didSet {
            updateAttributedText()
        }
    }
    var text: String = "" {
        didSet {
            self.updateAttributedText()
            if self.width <= 0 || self.height == "auto" {
                self.updateConstraint()
            }
            delegate?.onTextChanged(text, textItem: self)
        }
    }
    
    var textStep: Int = 0
    
    public func stepText (_ step: Int) {
        if textStep <= 0 {
            return
        }
        guard let digital = self.text.components(separatedBy: CharacterSet.decimalDigits.inverted).first, let value = Int(digital) else { return }
        let newValue = value + textStep * step
        self.text = self.text.replacingOccurrences(of: digital, with: String(format: "%d", newValue))
    }
    
    var label: UILabel? {
        return self.view as? UILabel
    }
    
    internal enum TextCodingKeys: String, CodingKey {
        case excel
        case lineSpacing
        case spacing
        case wordWrap
        case font
        case fontSize
        case bold
        case italic
        case underline
        case strike
        case watermark
        case align
        case text
        case textStep
    }
    
    init() {
        super.init(type: .text)
    }
    
    internal override init(type: ItemType) {
        super.init(type: type)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TextCodingKeys.self)
        if let value = try?container.decodeIfPresent(Excel.self, forKey: .excel), let trueValue = value {
            self.excel = trueValue
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .lineSpacing), let trueValue = value {
            self.lineSpacing = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Float.self, forKey: .spacing), let trueValue = value {
            self.spacing = trueValue
        }
        
        if let value = try? container.decodeIfPresent(String.self, forKey: .font), let trueValue = value {
            self.font = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Float.self, forKey: .fontSize), let trueValue = value {
            self.fontSize = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .bold), let trueValue = value {
            self.bold = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Int.self, forKey: .textStep), let trueValue = value {
            self.textStep = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .italic), let trueValue = value {
            self.italic = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .underline), let trueValue = value {
            self.underline = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .strike), let trueValue = value {
            self.strike = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .watermark), let trueValue = value {
            self.watermark = trueValue
        }
        
        if let value = try? container.decodeIfPresent(ItemAlign.self, forKey: .align), let trueValue = value {
            self.align = trueValue
        }
        
        if let value = try? container.decodeIfPresent(String.self, forKey: .text), let trueValue = value {
            self.text = trueValue
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: TextCodingKeys.self)
        try? contrainer.encode(excel, forKey: .excel)
        try? contrainer.encode(lineSpacing, forKey: .lineSpacing)
        try? contrainer.encode(spacing, forKey: .spacing)
        try? contrainer.encode(wordWrap, forKey: .wordWrap)
        try? contrainer.encode(font, forKey: .font)
        try? contrainer.encode(fontSize, forKey: .fontSize)
        try? contrainer.encode(bold, forKey: .bold)
        try? contrainer.encode(italic, forKey: .italic)
        try? contrainer.encode(textStep, forKey: .textStep)
        try? contrainer.encode(underline, forKey: .underline)
        try? contrainer.encode(strike, forKey: .strike)
        try? contrainer.encode(watermark, forKey: .watermark)
        try? contrainer.encode(align, forKey: .align)
        try? contrainer.encode(text, forKey: .text)
    }
    
    override public func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        self.view = label
        self.update()
    }
    
    override internal func update () {
        self.updateFont()
        self.updateWordWrap()
        self.updateAttributedText()
        super.update()
    }
    
    private func updateFont () {
        if let label = self.label, let tag = tag {
            let fontSize = CGFloat(self.fontSize) * tag.scale
            if font.isEmpty {
                if self.bold {
                    label.font = UIFont.boldSystemFont(ofSize: fontSize)
                } else {
                    let font = UIFont.systemFont(ofSize: fontSize)
                    label.font = font
                }
            } else {
                let fontNames = UIFont.fontNames(forFamilyName: font)
                var selectedFontName = fontNames.first ?? font
                if self.bold {
                    for fontName in fontNames {
                        if fontName.lowercased().contains("bold") {
                            selectedFontName = fontName
                            break
                        }
                    }
                }
                label.font = UIFont(name: selectedFontName, size: fontSize)
            }
            if self.italic {
                updateAttributedText()
            }
        }
    }
    
    private func updateWordWrap () {
        if let label = self.label {
            label.numberOfLines = wordWrap ? 0 : 1
            label.lineBreakMode = wordWrap ? .byCharWrapping : .byWordWrapping
        }
    }
    
    private func updateAttributedText () {
        if let label = self.label, let tag = tag {
            var text = self.text
            if text.isEmpty {
                if !excel.url.isEmpty && !excel.worksheet.isEmpty && !excel.column.isEmpty {
                    text = "Excel: \(excel.name)"
                } else {
                    text = NSLocalizedString("请输入文本内容", comment: "请输入文本内容")
                }
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = CGFloat(Float(self.fontSize) * self.lineSpacing) * tag.scale
            switch align {
                case .center:
                paragraphStyle.alignment = .center
                case .right:
                paragraphStyle.alignment = .right
                case .strech:
                paragraphStyle.alignment = .justified
                default:
                paragraphStyle.alignment = .left
            }
            var attributes: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.kern: self.spacing,
                NSAttributedStringKey.underlineStyle: self.underline ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue,
                NSAttributedStringKey.strikethroughStyle: self.strike ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue,
                NSAttributedStringKey.baselineOffset: NSNumber(value: 0)]
            
            if self.italic {
                let matrix = CGAffineTransform(a: 1, b: 0, c: tan(5 * CGFloat(Double.pi / 180)), d: 1, tx: 0, ty: 0)
                let font = UIFontDescriptor(name: label.font.fontName, matrix: matrix)
                let fontSize = CGFloat(self.fontSize) * tag.scale
                attributes[NSAttributedStringKey.font] = UIFont(descriptor: font, size: fontSize)
            }
            var attributedText = NSMutableAttributedString(string: text, attributes: attributes)
            if self.align == .strech {
                let labelWidth = self.frameWidth
                let textWidth = attributedText.boundingRect(with: CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine, .usesFontLeading], context: nil).size.width
                let margin = (labelWidth - textWidth)/CGFloat(attributedText.length - 1)
                attributes[NSAttributedStringKey.kern] = NSNumber(floatLiteral: Double(margin))
                attributedText = NSMutableAttributedString(string: text, attributes: attributes)
            }
            label.attributedText = attributedText
        }
    }
}
