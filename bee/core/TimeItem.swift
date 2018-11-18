//
//  TimeItem.swift
//  bee
//
//  Created by Herb on 2018/7/22.
//  Copyright © 2018 fenzotech. All rights reserved.
//

import UIKit

class TimeItem: TextItem {
    var dayFormatter: String = NSLocalizedString("yyyy年MM月dd日", comment: "yyyy年MM月dd日") {
        didSet {
            updateTime()
        }
    }
    var dayDateFormatter: DateFormatter? {
        if dayFormatter.isEmpty || dayFormatter == NSLocalizedString("无", comment: "无") {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = dayFormatter
        return formatter
    }
    
    var timeFormatter: String = NSLocalizedString("无", comment: "无") {
        didSet {
            updateTime()
        }
    }
    var timeDateFormatter: DateFormatter? {
        if timeFormatter.isEmpty || timeFormatter == NSLocalizedString("无", comment: "无") {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormatter
        return formatter
    }
    
    var offset: Int = 0 {
        didSet {
            updateTime()
        }
    }
    
    internal enum TimeCodingKeys: String, CodingKey {
        case dayFormatter
        case timeFormatter
        case offset
    }
    
    override init() {
        super.init(type: .time)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TimeCodingKeys.self)
        if let value = try?container.decodeIfPresent(String.self, forKey: .dayFormatter), let trueValue = value {
            self.dayFormatter = trueValue
        }
        if let value = try? container.decodeIfPresent(String.self, forKey: .timeFormatter), let trueValue = value {
            self.timeFormatter = trueValue
        }
        
        if let value = try? container.decodeIfPresent(Int.self, forKey: .offset), let trueValue = value {
            self.offset = trueValue
        }
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Swift.Encoder) throws {
        try super.encode(to: encoder)
        var contrainer = encoder.container(keyedBy: TimeCodingKeys.self)
        try? contrainer.encode(dayFormatter, forKey: .dayFormatter)
        try? contrainer.encode(timeFormatter, forKey: .timeFormatter)
        try? contrainer.encode(offset, forKey: .offset)
    }
    
    override func update() {
        self.updateTime()
        super.update()
    }
    
    func updateTime () {
        var now = Date()
        if self.offset > 0 {
            now = Calendar.current.date(byAdding: .day, value: self.offset, to: now)!
        }
        var texts = [String]()
        if let dayDateFormatter = self.dayDateFormatter {
            texts.append(dayDateFormatter.string(from: now))
        }
        if let timeDateFormatter = self.timeDateFormatter {
            texts.append(timeDateFormatter.string(from: now))
        }
        self.text = texts.joined(separator: " ")
    }
}
