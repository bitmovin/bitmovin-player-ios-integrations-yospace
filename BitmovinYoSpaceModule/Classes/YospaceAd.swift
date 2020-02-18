//
//  Ad.swift
//  BitmovinYospaceModule-iOS
//
//  Created by aneurinc on 2/14/20.
//

import Foundation
import BitmovinPlayer

//swiftlint:disable type_name
public class YospaceAd: NSObject, Ad {
    public private(set) var relativeStart: TimeInterval
    public var identifier: String?
    public private(set) var duration: TimeInterval
    public private(set) var hasInteractiveUnit: Bool
    public private(set) var absoluteStart: TimeInterval
    public private(set) var absoluteEnd: TimeInterval
    public var clickThroughUrl: URL?
    public var isLinear: Bool
    
    // Not supported
    public var width: Int = -1
    public var height: Int = -1
    public var mediaFileUrl: URL? = nil
    public var data: AdData? = nil

    init(identifier: String?, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, hasInteractiveUnit: Bool, isLinear: Bool, clickThroughUrl: URL?) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.isLinear = isLinear
        self.hasInteractiveUnit = hasInteractiveUnit
        self.clickThroughUrl = clickThroughUrl
    }
    
    public func toJsonString() throws -> String {
        return ""
    }
    
    public func toJsonData() -> [AnyHashable : Any] {
        return [:]
    }
    
    public static func fromJsonData(_ jsonData: [AnyHashable : Any]) throws -> Any {
        return jsonData
    }
    
    override public var debugDescription: String {
        return "id=\(self.identifier ?? "unknown") absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd)"
    }
}
//swiftlint:enable type_name
