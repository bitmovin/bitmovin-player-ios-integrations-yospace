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
    // swiftlint:disable identifier_name
    public let id: String?
    // swiftlint:enable identifier_name
    public let adSlotId: String?
    public let width: CGFloat?
    public let height: CGFloat?
    public let clickThroughUrl: String?
    public let resource: CompanionAdResource?

    var debugDescription: String {
        // swiftlint:disable line_length
        return "id=\(String(describing: id)), adSlotId=\(String(describing: adSlotId)), width=\(String(describing: width)), height=\(String(describing: height)), type=\(String(describing: resource?.type)) source=\(String(describing: resource?.source))"
        // swiftlint:enable line_length
    }
}
