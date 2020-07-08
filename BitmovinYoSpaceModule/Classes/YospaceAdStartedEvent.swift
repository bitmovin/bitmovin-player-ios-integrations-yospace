//
//  TrueXAdStartedEvent.swift
//  Pods
//
//  Created by Cory Zachman on 9/20/19.
//

import Foundation
import BitmovinPlayer

public class YospaceAdStartedEvent: AdStartedEvent {
    public var truexAd: Bool

    // swiftlint:disable identifier_name
    init(clickThroughUrl: URL?, clientType: BMPAdSourceType, indexInQueue: UInt, duration: TimeInterval, timeOffset: TimeInterval, skipOffset: TimeInterval, position: String?, ad: Ad?, truexAd: Bool = false) {
        // swiftlint:enable identifier_name
        self.truexAd = truexAd
        super.init(
            clickThroughUrl: clickThroughUrl,
            clientType: clientType,
            indexInQueue: indexInQueue,
            duration: duration,
            timeOffset: timeOffset,
            skipOffset: skipOffset,
            position: position,
            ad: ad
        )
    }
}
