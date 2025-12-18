//
//  Ad.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import BitmovinPlayerCore
import Foundation
import YOAdManagement

public class YospaceAd: NSObject, LinearAd {
    public var identifier: String?
    public let creativeId: String?
    public let sequence: String?
    public let absoluteStart: TimeInterval
    public let relativeStart: TimeInterval
    public var duration: TimeInterval
    public let absoluteEnd: TimeInterval
    public let system: String?
    public let title: String?
    public let advertiser: String?
    public let hasInteractiveUnit: Bool
    public let lineage: YOAdvertWrapper?
    public let extensions: [YOXmlNode]
    public let isFiller: Bool
    public let isLinear: Bool
    public var clickThroughUrl: URL?
    public var data: AdData?
    public var width: Int = -1
    public var height: Int = -1
    public var mediaFileUrl: URL?
    public var skippableAfter: TimeInterval
    public var uiConfig: BitmovinPlayerCore.LinearAdUiConfig?
    public var clickThroughUrlOpened: (() -> Void)?

    required init(
        identifier: String?,
        creativeId: String?,
        sequence: String?,
        absoluteStart: TimeInterval,
        relativeStart: TimeInterval,
        duration: TimeInterval,
        absoluteEnd: TimeInterval,
        system: String?,
        title: String?,
        advertiser: String?,
        hasInteractiveUnit: Bool,
        lineage: YOAdvertWrapper?,
        extensions: [YOXmlNode],
        isFiller: Bool,
        isLinear: Bool,
        clickThroughUrl: URL?,
        mediaFileUrl: URL?,
        skippableAfter: TimeInterval,
        clickThroughUrlOpened: (() -> Void)?
    ) {
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
        self.lineage = lineage
        self.extensions = extensions
        self.isFiller = isFiller
        self.isLinear = isLinear
        self.clickThroughUrl = clickThroughUrl
        self.mediaFileUrl = mediaFileUrl
        self.skippableAfter = skippableAfter
        self.clickThroughUrlOpened = clickThroughUrlOpened
    }

    override public var debugDescription: String {
        // swiftlint:disable line_length
        return "id=\(identifier ?? "unknown"), creativeId=\(creativeId ?? "") sequence=\(sequence ?? ""), absoluteStart=\(absoluteStart), relativeStart=\(relativeStart), duration=\(duration), absoluteEnd=\(absoluteEnd), system=\(system ?? ""), title=\(title ?? ""), advertiser=\(advertiser ?? ""), hasInteractiveUnit=\(hasInteractiveUnit), isFiller=\(isFiller), isLinear=\(isLinear), clickThroughUrl=\(clickThroughUrl?.absoluteString ?? "")"
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
