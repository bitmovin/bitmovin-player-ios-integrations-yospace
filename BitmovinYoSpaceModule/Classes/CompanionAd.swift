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
    // swiftlint:disable:next identifier_name
    public let id: String?
    public let adSlotId: String?
    public let width: CGFloat?
    public let height: CGFloat?
    public let clickThroughUrl: String?
    public let resource: CompanionAdResource?

    var debugDescription: String {
        let adIds = "id=\(id ?? "unknown"), adSlotId=\(adSlotId ?? "unknown")"
        let resolution = "width=\(width ?? -1), height=\(height ?? -1)"

        return "\(adIds), \(resolution), type=\(String(describing: resource?.type)) source=\(resource?.source ?? "unknown")"
    }
}
