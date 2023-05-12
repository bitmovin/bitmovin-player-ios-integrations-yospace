//
//  AdBreak.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import BitmovinPlayer
import Foundation

public class YospaceAdBreak: NSObject, AdBreak {
    public let identifier: String
    public let absoluteStart: TimeInterval
    public let relativeStart: TimeInterval
    public let duration: TimeInterval
    public let absoluteEnd: TimeInterval
    public private(set) var ads: [Ad] = []
    public var scheduleTime: TimeInterval
    public var replaceContentDuration: TimeInterval
    public let position: YospaceAdBreakPosition

    required init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, scheduleTime: TimeInterval, replaceContentDuration: TimeInterval, position: YospaceAdBreakPosition = .unknown) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.scheduleTime = scheduleTime
        self.replaceContentDuration = replaceContentDuration
        self.position = position
    }

    public func register(_ adItem: Ad) {
        ads.append(adItem)
    }

    override public var debugDescription: String {
        // swiftlint:disable line_length
        return "id=\(identifier), relativeStart=\(relativeStart), absoluteStart=\(absoluteStart), duration=\(duration), absoluteEnd=\(absoluteEnd), scheduleTime=\(scheduleTime), replaceContentDuration=\(replaceContentDuration), position=\(position.rawValue), ads=\(ads.count)"
        // swiftlint:enable line_length
    }

    // Implementation of protocol is required, but we do not need to support JSON mapping, so default values are used
    public func _toJsonString() throws -> String {
        return ""
    }

    public func _toJsonData() -> [AnyHashable: Any] {
        return [:]
    }
}
