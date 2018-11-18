//
//  TableItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TableItem: Item {
    var columns: Int = 2 {
        didSet {
            updateTable()
        }
    }
    var rows: Int = 2 {
        didSet {
            updateTable()
        }
    }
    var borderWidth: Float = 1 {
        didSet {
            updateTable()
        }
    }
    var columnWidths: [Int: Float] = [:] {
        didSet {
            updateTable()
        }
    }
    var rowHeights: [Int: Float] = [:] {
        didSet {
            updateTable()
        }
    }
    var texts = [TextItem]()
    var text: TextItem? {
        didSet {
            oldValue?.view?.backgroundColor = nil
            text?.view?.backgroundColor = UIColor("#FABE00")
        }
    }
    
    internal enum TableCodingKeys: String, CodingKey {
        case columns
        case rows
        case borderWidth
        case columnWidths
        case rowHeights
        case texts
    }
    
    init() {
        super.init(type: .table)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TableCodingKeys.self)
        if let value = try? container.decodeIfPresent(Int.self, forKey: .columns), let nonNil = value {
            self.columns = nonNil
        }
        if let value = try? container.decodeIfPresent(Int.self, forKey: .rows), let nonNil = value {
            self.rows = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .borderWidth), let nonNil = value {
            self.borderWidth = nonNil
        }
        if let value = try? container.decodeIfPresent([Int: Float].self, forKey: .columnWidths), let nonNil = value {
            self.columnWidths = nonNil
        }
        if let value = try? container.decodeIfPresent([Int: Float].self, forKey: .rowHeights), let nonNil = value {
            self.rowHeights = nonNil
        }
        if let value = try? container.decodeIfPresent([TextItem].self, forKey: .texts), let nonNil = value {
            self.texts = nonNil
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: TableCodingKeys.self)
        try? contrainer.encode(columns, forKey: .columns)
        try? contrainer.encode(rows, forKey: .rows)
        try? contrainer.encode(borderWidth, forKey: .borderWidth)
        try? contrainer.encode(columnWidths, forKey: .columnWidths)
        try? contrainer.encode(rowHeights, forKey: .rowHeights)
        try? contrainer.encode(texts, forKey: .texts)
    }
    
    override public func bindView(contrainer: UIView) {
        super.bindView(contrainer: contrainer)
        let view = UIView()
        view.clipsToBounds = true
        self.view = view
        self.update()
    }
    
    override func caculateWidth () -> CGFloat {
        var width: CGFloat = 0
        for row in 0..<rows  {
            var rowWidth: CGFloat = 0
            for column in 0..<columns {
                let columnWidth = columnWidths[column, default: 0]
                if columnWidth > 0 {
                    rowWidth += CGFloat(columnWidth) * (tag?.scale ?? 1)
                } else {
                    let text = texts[row*columns + column]
                    rowWidth += text.caculateWidth()
                }
            }
            if rowWidth > width {
                width = rowWidth
            }
        }
        return width
    }
    
    override func caculateHeight (_ width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        for row in 0..<rows {
            let rowHeight = rowHeights[row, default: 0]
            if rowHeight > 0 {
                height += CGFloat(rowHeight) * (tag?.scale ?? 1)
            } else {
                var maxHeight: CGFloat = 0
                for column in 0..<columns {
                    let text = texts[row*columns + column]
                    
                    var columnWidth = CGFloat(columnWidths[column, default: 0])
                    if columnWidth > 0 {
                        columnWidth = CGFloat(columnWidth) * (tag?.scale ?? 1)
                    } else {
                        columnWidth = text.caculateWidth()
                    }
                    let columnHeight = text.caculateHeight(columnWidth)
                    if columnHeight > maxHeight {
                        maxHeight = columnHeight
                    }
                }
                height += maxHeight
            }
        }
        return height
    }
    
    override internal func update () {
        self.updateTable()
        super.update()
    }
    
    override func tagChanged() {
        super.tagChanged()
        texts.forEach { (text) in
            text.tag = self.tag
        }
    }
    
    override func updateConstraint() {
        super.updateConstraint()
        updateTable()
    }
    
    @objc override func handleTap(tapGesture: UITapGestureRecognizer) {
        for item in self.texts.reversed() {
            if let view = item.view {
                let location = tapGesture.location(in: view)
                if view.point(inside: location, with: nil) {
                    self.text = item
                    return
                }
            }
        }
        self.text = nil
    }
    
    func updateTable () {
        guard let view = self.view else { return }
        guard let tag = self.tag else { return }
        let borderColor = UIColor.black
        var texts = [TextItem]()
        var index = 0
        for row in 0..<rows  {
            var rowView: UIView
            if row < view.subviews.count {
                rowView = view.subviews[row]
            } else {
                rowView = UIView()
                view.addSubview(rowView)
            }
            
            var maxHeight: CGFloat = 0
            for column in 0..<columns {
                let text: TextItem
                if (index < self.texts.count) {
                    text = self.texts[index]
                } else {
                    text = TextItem()
                    text.tag = tag
                    text.align = .center
                }
                texts.append(text)
                index += 1
                
                var width = CGFloat(columnWidths[column] ?? 0) * tag.scale
                var height = CGFloat(rowHeights[row, default: 0]) * tag.scale
                
                var cellView: UIView
                if column < rowView.subviews.count {
                    cellView = rowView.subviews[column]
                } else {
                    cellView = UIView()
                    rowView.addSubview(cellView)
                }
                
                text.bindView(contrainer: cellView)
                text.label?.snp.makeConstraints { (make) in
                    make.edges.equalTo(cellView)
                }
                
                if width <= 0 {
                    if self.width > 0 {
                        width = CGFloat(self.width) * tag.scale / CGFloat(columns)
                    } else {
                        width = text.caculateWidth()
                    }
                }
                if height <= 0 {
                    if let selfH = Float(self.height), selfH > 0 {
                        height = CGFloat(selfH) * tag.scale / CGFloat(rows)
                    } else {
                        height = text.caculateHeight(width)
                    }
                }
                if height > maxHeight {
                    maxHeight = height
                }
                
                cellView.snp.remakeConstraints { (make) in
                    if column == 0 {
                        make.leading.equalTo(rowView)
                    } else {
                        let prev = rowView.subviews[column - 1]
                        make.leading.equalTo(prev.snp.trailing)
                    }
                    if width > 0 {
                        make.width.equalTo(width)
                    }
                    if column + 1 == columns {
                        make.trailing.equalTo(rowView)
                    }
                    make.top.equalTo(rowView)
                    make.bottom.equalTo(rowView)
                }
                let frameSize = CGSize(width: width, height: height)
                cellView.addPath(frameSize: frameSize, path: Shape.rect.getPath(frameSize), strokeColor: borderColor, fillColor: UIColor.clear, lineWidth: CGFloat(self.borderWidth))
            }
            
            for i in columns..<rowView.subviews.count {
                rowView.subviews[i].removeFromSuperview()
            }
            
            rowView.snp.remakeConstraints { (make) in
                if row == 0 {
                    make.top.equalTo(view)
                } else {
                    let prev = view.subviews[row - 1]
                    make.top.equalTo(prev.snp.bottom)
                }
                make.leading.equalTo(view)
                make.height.equalTo(maxHeight)
                
                if row + 1 == rows {
                    make.trailing.equalTo(view)
                }
            }
        }
        for i in rows..<view.subviews.count {
            view.subviews[i].removeFromSuperview()
        }
        self.texts = texts
    }
}
