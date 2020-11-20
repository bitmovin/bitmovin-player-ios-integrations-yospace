//
//  CompanionAd.swift
//  Pods
//
//  Created by aneurinc on 10/29/20.
//

import Foundation

public enum CompanionAdType {
    case html
    case `static`
}

public struct CompanionAdResource {
    public let source: String?
    public let type: CompanionAdType
}

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
