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
    public private(set) var relativeStart: TimeInterval = 0.0
    public var identifier: String? = "unknown"
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var hasInteractiveUnit = false
    public private(set) var absoluteStart: TimeInterval = 0.0
    public private(set) var absoluteEnd: TimeInterval = 0.0
    public var clickThroughUrl: URL?
    public var isLinear: Bool
    public var width: Int
    public var height: Int
    public var mediaFileUrl: URL?
    public var data: AdData?

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, hasInteractiveUnit: Bool, isLinear: Bool, clickThroughUrl: URL?, data: AdData?) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.isLinear = isLinear
        self.hasInteractiveUnit = hasInteractiveUnit
        self.clickThroughUrl = clickThroughUrl
        self.data = data
        
        // Not supported
        self.width = -1
        self.height = -1
        self.mediaFileUrl = nil
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
        return "id=\(self.identifier ?? "") absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd)"
    }
}
//swiftlint:enable type_name
