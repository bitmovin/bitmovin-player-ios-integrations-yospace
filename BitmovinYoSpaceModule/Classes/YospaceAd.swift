//
//  Ad.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import Foundation
import BitmovinPlayer
import Yospace

public class YospaceAd: NSObject, Ad {
    public var identifier: String?
    public private(set) var absoluteStart: TimeInterval
    public private(set) var absoluteEnd: TimeInterval
    public private(set) var duration: TimeInterval
    public private(set) var relativeStart: TimeInterval
    public private(set) var hasInteractiveUnit: Bool
    public private(set) var isLinear: Bool
    public var clickThroughUrl: URL?
    public private(set) var extensions: [YSXmlNode]

    // Not supported
    public var width: Int = -1
    public var height: Int = -1
    public var mediaFileUrl: URL?
    public var data: AdData?

    init(identifier: String?, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, hasInteractiveUnit: Bool = false, isLinear: Bool = false, clickThroughUrl: URL? = nil, extensions: [YSXmlNode] = [YSXmlNode]()) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.isLinear = isLinear
        self.hasInteractiveUnit = hasInteractiveUnit
        self.clickThroughUrl = clickThroughUrl
        self.extensions = extensions
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
        // swiftlint:disable line_length
        return "id=\(identifier ?? "unknown"), relativeStart=\(relativeStart), absoluteStart=\(absoluteStart), duration=\(duration), absoluteEnd=\(absoluteEnd)"
        // swiftlint:enable line_length
    }
}
