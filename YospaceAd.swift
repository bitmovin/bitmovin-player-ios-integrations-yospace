//
//  Ad.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import Foundation

//swiftlint:disable type_name
public class YospaceAd: CustomDebugStringConvertible {
    public private(set) var relativeStart: TimeInterval = 0.0
    public private(set) var identifier: String = "unknown"
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var hasInteractiveUnit = false
    public private(set) var absoluteStart: TimeInterval = 0.0
    public private(set) var absoluteEnd: TimeInterval = 0.0
    public private(set) var clickThroughUrl: URL?

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, hasInteractiveUnit: Bool, clickThroughUrl: URL?) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.hasInteractiveUnit = hasInteractiveUnit
        self.clickThroughUrl = clickThroughUrl
    }

    public var debugDescription: String {
        return "id=\(self.identifier) absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd)"
    }

}
//swiftlint:enable type_name
