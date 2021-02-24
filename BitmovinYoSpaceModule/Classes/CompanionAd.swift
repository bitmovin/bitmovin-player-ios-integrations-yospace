//
//  CompanionAd.swift
//  Pods
//
//  Created by aneurinc on 10/29/20.
//

import Foundation

@frozen
public enum CompanionAdType {
    case html
    case `static`
}

@frozen
public struct CompanionAdResource {
    public let source: String?
    public let type: CompanionAdType
}

@frozen
public struct CompanionAd {
    public let id: String?
    public let adSlotId: String?
    public let width: CGFloat?
    public let height: CGFloat?
    public let clickThroughUrl: String?
    public let resource: CompanionAdResource?

    var debugDescription: String {
        return "id=\(id), adSlotId=\(adSlotId), width=\(width), height=\(height), type=\(resource?.type) source=\(resource?.source)"
    }
}
