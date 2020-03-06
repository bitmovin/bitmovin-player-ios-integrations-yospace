//
//  AdBreak.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import Foundation
import BitmovinPlayer

public class YospaceAdBreak: NSObject, AdBreak {
    public private(set) var relativeStart: TimeInterval
    public private(set) var duration: TimeInterval
    public private(set) var absoluteStart: TimeInterval
    public private(set) var absoluteEnd: TimeInterval
    public private(set) var identifier: String
    public private(set) var ads: [Ad] = []
    public var scheduleTime: TimeInterval
    public var replaceContentDuration: TimeInterval

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, scheduleTime: TimeInterval, replaceContentDuration: TimeInterval) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.scheduleTime = scheduleTime
        self.replaceContentDuration = replaceContentDuration
    }

    public func register(_ adItem: Ad) {
        self.ads.append(adItem)
    }

    public func toJsonString() throws -> String {
        return ""
    }

    public func toJsonData() -> [AnyHashable: Any] {
        return [:]
    }

    public static func fromJsonData(_ jsonData: [AnyHashable: Any]) throws -> Any {
        return jsonData
    }

    override public var debugDescription: String {
        return "id=\(self.identifier) absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd) ads=\(ads.map {$0.identifier})"
    }
}
