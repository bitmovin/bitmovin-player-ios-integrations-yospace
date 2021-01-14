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
    public let creativeId: String?
    public let sequence: String?
    public let absoluteStart: TimeInterval
    public let relativeStart: TimeInterval
    public let duration: TimeInterval
    public let absoluteEnd: TimeInterval
    public let system: String?
    public let title: String?
    public let advertiser: String?
    public let hasInteractiveUnit: Bool
    public let extensions: [YSXmlNode]
    public let isFiller: Bool
    public let isLinear: Bool
    public var clickThroughUrl: URL?
    public var data: AdData?
    public var width: Int = -1
    public var height: Int = -1
    public var mediaFileUrl: URL?

    required init(identifier: String?, creativeId: String?, sequence: String?, absoluteStart: TimeInterval, relativeStart: TimeInterval, duration: TimeInterval, absoluteEnd: TimeInterval, system: String?, title: String?, advertiser: String?, hasInteractiveUnit: Bool, extensions: [YSXmlNode], isFiller: Bool, isLinear: Bool, clickThroughUrl: URL?, mediaFileUrl: URL?) {
        self.identifier = identifier
        self.creativeId = creativeId
        self.sequence = sequence
        self.absoluteStart = absoluteStart
        self.relativeStart = relativeStart
        self.duration = duration
        self.absoluteEnd = absoluteEnd
        self.system = system
        self.title = title
        self.advertiser = advertiser
        self.hasInteractiveUnit = hasInteractiveUnit
        self.extensions = extensions
        self.isFiller = isFiller
        self.isLinear = isLinear
        self.clickThroughUrl = clickThroughUrl
        self.mediaFileUrl = mediaFileUrl
    }

    override public var debugDescription: String {
        // swiftlint:disable line_length
        return "id=\(identifier ?? "unknown"), creativeId=\(creativeId ?? "") sequence=\(sequence ?? ""), absoluteStart=\(absoluteStart), relativeStart=\(relativeStart), duration=\(duration), absoluteEnd=\(absoluteEnd), system=\(system ?? ""), title=\(title ?? ""), advertiser=\(advertiser ?? ""), hasInteractiveUnit=\(hasInteractiveUnit), isFiller=\(isFiller), isLinear=\(isLinear), clickThroughUrl=\(clickThroughUrl)"
        // swiftlint:enable line_length
    }
}

// Implementation of protocol is required, but we do not need to support JSON mapping, so default values are used
extension YospaceAd: BMPJsonable {
    public func toJsonString() throws -> String {
        return ""
    }

    public func toJsonData() -> [AnyHashable: Any] {
        return [:]
    }

    public static func fromJsonData(_ jsonData: [AnyHashable: Any]) throws -> Self {
        return Self.init(
            identifier: nil,
            creativeId: nil,
            sequence: nil,
            absoluteStart: 0,
            relativeStart: 0,
            duration: 0,
            absoluteEnd: 0,
            system: nil,
            title: nil,
            advertiser: nil,
            hasInteractiveUnit: false,
            extensions: [],
            isFiller: false,
            isLinear: false,
            clickThroughUrl: nil,
            mediaFileUrl: nil
        )
    }
}
