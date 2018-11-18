//
//  Tag.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit
import SnapKit

enum PageIntervalType: String, Codable {
    case continuous
    case hole
    case gap
    case black_marker
    
    public var label: String {
        switch self {
        case .continuous:
            return NSLocalizedString("连续纸", comment: "连续纸")
        case .hole:
            return NSLocalizedString("定位孔", comment: "定位孔")
        case .gap:
            return NSLocalizedString("间隙纸", comment: "间隙纸")
        case .black_marker:
            return NSLocalizedString("黑标纸", comment: "黑标纸")
        }
    }
    
    public var papaerTypeValue: Int32 {
        switch self {
        case .continuous:
            return 0x10
        default:
            return 0x20
        }
    }
    
    public var value: Int32 {
        switch self {
        case .continuous:
            return 0x10
        case .hole:
            return 0x20
        case .gap:
            return 0x20
        case .black_marker:
            return 0x30
        }
    }
    
    init?(tag: Int) {
        switch tag {
        case 0: self = .continuous
        case 1: self = .hole
        case 2: self = .gap
        case 3: self = .black_marker
        default: return nil
        }
    }
}

enum TagTailDirection: String, Codable {
    case up
    case down
    case right
    case left
    
    public var label: String {
        switch self {
        case .up:
            return NSLocalizedString("朝上", comment: "朝上")
        case .down:
            return NSLocalizedString("朝下", comment: "朝下")
        case .left:
            return NSLocalizedString("朝左", comment: "朝左")
        case .right:
            return NSLocalizedString("朝右", comment: "朝右")
        }
    }
    
    init?(tag: Int) {
        switch tag {
        case 0: self = .up
        case 1: self = .down
        case 2: self = .left
        case 3: self = .right
        default: return nil
        }
    }
}

protocol TagDelegate: class {
    
    func currentChanged(tag: Tag)
    func itemDoubleTaped(tag: Tag, item: Item)
    func historyChanged(tag: Tag)
}

class Tag: Codable {
    weak var delegate: TagDelegate? = nil
    
    var width: Float = 40 {
        didSet {
            updateAspect()
        }
    }
    var height: Float = 30 {
        didSet {
            updateAspect()
        }
    }
    var background: String = "" {
        didSet {
            updateBackground()
        }
    }
    
    var scale: CGFloat {
        var width = self.view?.bounds.size.width ?? 0
        if width <= 0 {
            width = CGFloat(self.width)
        }
        let scale = width / CGFloat(self.width)
        return scale
    }
    
    var createdAt: Date = Date()
    var angel: Int = 0
    var flag: Bool = false
    var mirror: Bool = false
    var pageIntervalType: PageIntervalType = .gap
    var tailDirection: TagTailDirection = .up
    var tailLength: Float = 0
    var printConcentration: Float = 10
    var printSpeed: Float = 1
    var printVericalOffset: Float = 0
    var printHorizontalOffset: Float = 0
    var items: [Item] = [] {
        didSet {
            syncTag()
        }
    }
    var locked: Bool = false
    var gap: Float = 0
    
    var currentTextItem: TextItem? {
        return self.current?.textItem
    }
    
    var currentExcel: Excel? {
        return currentTextItem?.excel
    }
    
    private enum CodingKeys: String, CodingKey {
        case createdAt
        case width
        case height
        case background
        
        case angel
        case flag
        case mirror
        case pageIntervalType
        case tailDirection
        case tailLength
        case printConcentration
        case printSpeed
        case printVericalOffset
        case printHorizontalOffset
        case items
        case locked
        case gap
    }

    weak var view: UIView?
    var backgroundView: UIImageView? {
        guard let view = view else { return nil }
        let tag = 10000
        if let imageView = view.viewWithTag(tag) as? UIImageView {
            return imageView
        }
        let backgroundView = UIImageView()
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.tag = tag
        view.insertSubview(backgroundView, at: 0)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        return backgroundView
    }
    
    var selectionViews = [SelectionView]()
    var currents = [Item]() {
        didSet {
            for (index, item) in currents.enumerated() {
                let selectionView: SelectionView
                if index < selectionViews.count {
                    selectionView = selectionViews[index]
                } else {
                    selectionView = SelectionView()
                    selectionView.delegate = self
                    selectionViews.append(selectionView)
                }
                if (selectionView.superview == nil) {
                    view?.addSubview(selectionView)
                }
                selectionView.bind(item)
            }
            let from = currents.count
            if from < selectionViews.count {
                for index in from..<selectionViews.count {
                    selectionViews[index].removeFromSuperview()
                }
            }
            
            delegate?.currentChanged(tag: self)
        }
    }
    var current: Item? {
        get {
            return currents.last
        }
        
        set {
            if !allowMultiSelections {
                currents.removeAll()
            }
            if let item = newValue {
                let count = currents.count
                currents.removeAll { (aItem) -> Bool in
                    return aItem === item
                }
                if allowMultiSelections, count != currents.count {
                    return
                }
                currents.append(item)
            }
        }
    }
    
    var initXY: (Float, Float)?
    var initSize: (Float, Float)?
    var initFontSize: Float?
    var touchLocation: CGPoint?
    var constraints: [Constraint] = [] {
        didSet {
            for constraint in oldValue {
                constraint.deactivate()
            }
            for constraint in constraints {
                constraint.activate()
            }
        }
    }
    
    var histories = [Tag]()
    var historyIndex: Int = 0
    var allowMultiSelections = false {
        didSet {
            if self.currents.count > 1 {
                self.currents.removeFirst(self.currents.count - 1)
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(Date.self, forKey: .createdAt), let nonNil = value {
            self.createdAt = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .width), let nonNil = value {
            self.width = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .height), let nonNil = value {
            self.height = nonNil
        }
        if let value = try? container.decodeIfPresent(String.self, forKey: .background), let nonNil = value {
            self.background = nonNil
        }
        if let value = try? container.decodeIfPresent(Int.self, forKey: .angel), let nonNil = value {
            self.angel = nonNil
        }
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .flag), let nonNil = value {
            self.flag = nonNil
        }
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .mirror), let nonNil = value {
            self.mirror = nonNil
        }
        if let value = try? container.decodeIfPresent(PageIntervalType.self, forKey: .pageIntervalType), let nonNil = value {
            self.pageIntervalType = nonNil
        }
        if let value = try? container.decodeIfPresent(TagTailDirection.self, forKey: .tailDirection), let nonNil = value {
            self.tailDirection = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .tailLength), let nonNil = value {
            self.tailLength = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .printConcentration), let nonNil = value {
            self.printConcentration = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .printSpeed), let nonNil = value {
            self.printSpeed = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .printVericalOffset), let nonNil = value {
            self.printVericalOffset = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .printHorizontalOffset), let nonNil = value {
            self.printHorizontalOffset = nonNil
        }
        if let value = try? container.decodeIfPresent(Bool.self, forKey: .locked), let nonNil = value {
            self.locked = nonNil
        }
        if let value = try? container.decodeIfPresent(Float.self, forKey: .gap), let nonNil = value {
            self.gap = nonNil
        }
        
        if let value = try? container.decode([Item].self, ofFamily: ItemType.self, forKey: .items) {
            self.items = value
        } else {
            self.items = []
        }
        syncTag()
    }
    
    init() {
    }
    
    func resetHistories () {
        histories.removeAll()
        histories.append(self.clone())
        historyIndex = 0
        
        delegate?.historyChanged(tag: self)
    }
    
    func keepHistory () {
        if let last = histories.last {
            let lastData = try! JSONEncoder().encode(last)
            let selfData = try! JSONEncoder().encode(self)
            if lastData == selfData {
                return
            }
        }
        histories.append(self.clone())
        if histories.count > 50 {
            histories.remove(at: 0)
        }
        historyIndex = histories.count - 1
        
        delegate?.historyChanged(tag: self)
    }
    
    func backward () -> Tag {
        let next = historyIndex - 1
        return pop(next)
    }
    
    var canBackward: Bool {
        let next = historyIndex - 1
        return next >= 0
    }
    
    func pop(_ next: Int) -> Tag {
        let tag = histories[next].clone()
        tag.histories = histories
        tag.historyIndex = next
        delegate?.historyChanged(tag: tag)
        return tag
    }
    
    func forward () -> Tag {
        let next = historyIndex + 1
        return pop(next)
    }
    
    var canForward: Bool {
        let next = historyIndex + 1
        return next < histories.count
    }
    
    func encode(to encoder: Swift.Encoder) throws {
        var contrainer = encoder.container(keyedBy: CodingKeys.self)
        try? contrainer.encode(createdAt, forKey: .createdAt)
        try? contrainer.encode(width, forKey: .width)
        try? contrainer.encode(height, forKey: .height)
        try? contrainer.encode(background, forKey: .background)
        try? contrainer.encode(angel, forKey: .angel)
        try? contrainer.encode(flag, forKey: .flag)
        try? contrainer.encode(mirror, forKey: .mirror)
        try? contrainer.encode(pageIntervalType, forKey: .pageIntervalType)
        try? contrainer.encode(tailDirection, forKey: .tailDirection)
        try? contrainer.encode(tailLength, forKey: .tailLength)
        try? contrainer.encode(printConcentration, forKey: .printConcentration)
        try? contrainer.encode(printSpeed, forKey: .printSpeed)
        try? contrainer.encode(printVericalOffset, forKey: .printVericalOffset)
        try? contrainer.encode(printHorizontalOffset, forKey: .printHorizontalOffset)
        try? contrainer.encode(items, forKey: .items)
        try? contrainer.encode(locked, forKey: .locked)
        try? contrainer.encode(gap, forKey: .gap)
    }
    
    func syncTag () {
        for item in items {
            item.tag = self
        }
    }
    
    func clone() -> Tag {
        let data = try! JSONEncoder().encode(self)
        let decoder = JSONDecoder()
        let copy = try! decoder.decode(Tag.self, from: data)
        return copy
    }
    
    private func update () {
        self.updateAspect()
        self.updateBackground()
    }
    
    private func updateBackground () {
        if let imageView = self.backgroundView {
            if !background.isEmpty, let qiniuUrl = background.qiniuURL {
                imageView.isHidden = false
                imageView.af_setImage(withURL: qiniuUrl)
            } else {
                imageView.isHidden = true
            }
        }
    }
    
    private func updateAspect() {
        if let view = self.view {
            self.constraints = view.snp.prepareConstraints { (make) in
                make.height.equalTo(
                    view.snp.width).multipliedBy(
                        Double(self.height) / Double(self.width))
            }
        }
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        for item in self.items.reversed() {
            if let view = item.view {
                let location = tapGesture.location(in: view)
                if view.point(inside: location, with: nil) {
                    if item === self.current {
                        item.handleTap(tapGesture: tapGesture)
                    } else {
                        self.current?.handleTap(tapGesture: tapGesture)
                    }
                    self.current = item
                    return
                }
            }
        }
        self.current = nil
    }
    
    @objc func handleDoubleTap(tapGesture: UITapGestureRecognizer) {
        for item in self.items.reversed() {
            if let view = item.view {
                let location = tapGesture.location(in: view)
                if view.point(inside: location, with: nil) {
                    if item === self.current {
                        delegate?.itemDoubleTaped(tag: self, item: item)
                        return
                    }
                }
            }
        }
    }

    public func bindView(view: UIView, onlyPrintable: Bool = false, showBackground: Bool = true) {
        let oldView = self.view
        if let oldView = oldView, let gestureRecognizers = oldView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                oldView.removeGestureRecognizer(gestureRecognizer)
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Tag.handleTap(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(Tag.handleDoubleTap(tapGesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.require(toFail: doubleTapGesture)

        view.layoutIfNeeded()
        self.view = view
        if oldView != view {
            self.update()
        }
        if !showBackground {
            // 隐藏背景
            self.backgroundView?.isHidden = true
        }
        
        for item in self.items {
            if onlyPrintable && !item.printable {
                continue
            }
            item.bindView(contrainer: view)
        }
    }
    
    public func addItem(_ item: Item) {
        if checkIsLock() {
            return
        }
        
        self.items.append(item)
        if let view = self.view {
            item.bindView(contrainer: view)
        }
        self.current = item
        
        keepHistory()
    }
    
    public func moveItem(_ item: Item, toFront: Bool) {
        if checkIsLock() {
            return
        }
        
        guard let index = items.firstIndex(where: { (aItem) -> Bool in
            return aItem === item
        }) else { return }
        let toIndex = index + (toFront ? 1 : -1)
        if toIndex < 0 || toIndex >= items.count {
            return
        }
        items.remove(at: index)
        items.insert(item, at: toIndex)
        
        if let view = item.view {
            self.view?.insertSubview(view, at: toIndex)
        }
        
        keepHistory()
    }
    
    public func removeItem(_ item: Item) {
        if checkIsLock() {
            return
        }
        
        if let index = self.currents.index(where: { (aItem) -> Bool in
            return aItem === item
        })  {
            self.currents.remove(at: index)
        }
        if let index = self.items.index(where: { (aItem) -> Bool in
            return aItem === item
        }) {
            self.items.remove(at: index)
            if let view = item.view {
                view.removeFromSuperview()
            }
        }
        
        keepHistory()
    }
}

extension Tag: SelectionViewDelegate {
    func handlePan(_ selectionView: SelectionView, sender: UIPanGestureRecognizer) {
        guard let current = self.current else { return }
        if checkIsLock() {
            return
        }
        let scale = self.scale
        if sender.state == .began {
            let x = current.x == center ? (self.width - Float(current.frameWidth/scale)) * 0.5: Float(current.x) ?? 0
            let y = current.y == center ? (self.height - Float(current.frameHeight/scale)) * 0.5: Float(current.y) ?? 0
            self.initXY = (x, y)
        } else {
            guard let initXY = self.initXY else { return }
            if sender.state == .ended {
//                if let origin = current.view?.frame.origin {
//                    current.x = String(Float(origin.x / scale))
//                    current.y = String(Float(origin.y / scale))
//                }
                keepHistory()
            } else {
                let translation = sender.translation(in: self.view)
                current.x = String(initXY.0 + Float(translation.x / scale))
                current.y = String(initXY.1 + Float(translation.y / scale))
            }
        }
    }
    
    func handleClose(_ selectionView: SelectionView) {
        if let current = selectionView.item {
            self.removeItem(current)
        }
    }
    
    func syncRotate (item: Item) {
        for selectionView in selectionViews {
            if selectionView.item === item {
                if let transform = item.view?.transform {
                    selectionView.transform = transform
                }
                return
            }
        }
    }
    
    func handleRotate(_ selectionView: SelectionView) {
        if checkIsLock() {
            return
        }
        guard let item = selectionView.item else { return }
        let angel = item.angel + 90
        let x = angel.remainderReportingOverflow(dividingBy: 360)
        item.angel = x.partialValue
        
        if let transform = item.view?.transform {
            selectionView.transform = transform
        }
        
        keepHistory()
    }
    
    func handleZoomExist(_ selectionView: SelectionView, event: UIEvent) {
        self.initSize = nil
        self.initFontSize = nil
        self.touchLocation = nil
        
        keepHistory()
    }
    
    func handleZoom(_ selectionView: SelectionView, event: UIEvent) {
        if checkIsLock() {
            return
        }
        guard let current = selectionView.item else { return }
        guard let touch = event.allTouches?.first else { return }
        let location = touch.location(in: self.view)
        if let initSize = self.initSize, let touchLocation = self.touchLocation {
            let width = Float((location.x - touchLocation.x)/self.scale)
            let height = Float((location.y - touchLocation.y)/self.scale)
            current.width = initSize.0 + width
            current.height = String(format: "%f", initSize.1 + height)
//            if let text = current as? TextItem, let initFontSize = self.initFontSize {
//                let average = current.width/initSize.0
//                text.fontSize = average*initFontSize
//            }
        } else {
            let width = current.width > 0 ? current.width : Float((current.view?.bounds.size.width ?? 0)/self.scale)
            let height: Float
            if let selfHeight = Float(current.height) {
                height = selfHeight
            } else {
                height = Float((current.view?.bounds.size.height ?? 0) / self.scale)
            }
            self.initSize = (width, height)
            self.touchLocation = location
            if let text = current as? TextItem {
                self.initFontSize = text.fontSize
            }
        }
    }
    
    func checkIsLock () -> Bool {
        if locked {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("标签已锁定", comment: "标签已锁定"))
            return true
        }
        guard let current = self.current else { return false }
        if current.locked {
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("选中对象已锁定", comment: "选中对象已锁定"))
            return true
        }
        return false
    }
}
