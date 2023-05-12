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
    public var totalNumberOfAds: UInt

    required init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, scheduleTime: TimeInterval, replaceContentDuration: TimeInterval, position: YospaceAdBreakPosition = .unknown) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.scheduleTime = scheduleTime
        self.replaceContentDuration = replaceContentDuration
        self.position = position
        self.totalNumberOfAds = UInt(ads.count)
    }

    public func register(_ adItem: Ad) {
        ads.append(adItem)
        totalNumberOfAds = UInt(ads.count)
    }

    override public var debugDescription: String {
        // swiftlint:disable line_length
        return "id=\(identifier), relativeStart=\(relativeStart), absoluteStart=\(absoluteStart), duration=\(duration), absoluteEnd=\(absoluteEnd), scheduleTime=\(scheduleTime), replaceContentDuration=\(replaceContentDuration), position=\(position.rawValue), ads=\(ads.count)"
        // swiftlint:enable line_length
    }

    // Implementation of protocol is required, but we do not need to support JSON mapping, so default values are used

    // swiftlint:disable:next identifier_name
    public func _toJsonString() throws -> String {
        return ""
    }

    // swiftlint:disable:next identifier_name
    public func _toJsonData() -> [AnyHashable: Any] {
        return [:]
    }
}
