//
//  AdBreak.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import Foundation

public class YospaceAdBreak: CustomDebugStringConvertible {
    public private(set) var relativeStart: TimeInterval = 0.0
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var absoluteStart: TimeInterval = 0.0
    public private(set) var absoluteEnd: TimeInterval = 0.0
    public private(set) var identifier: String = "unknown"
    public private(set) var ads: [YospaceAd] = []

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
    }

    //swiftlint:disable identifier_name
    func appendAd(ad: YospaceAd) {
        self.ads.append(ad)
    }
    //swiftlint:enable identifier_name

    public var debugDescription: String {
        return "id=\(self.identifier) absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd) ads=\(ads.map {$0.identifier})"
    }

}
