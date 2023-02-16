//
//  TrueXAdStartedEvent.swift
//  Pods
//
//  Created by Cory Zachman on 9/20/19.
//

import Foundation
import BitmovinPlayer
import YOAdManagement

public class YospaceAdStartedEvent: AdStartedEvent {
    public var companionAds: [CompanionAd]

    init(
        clickThroughUrl: URL?,
        clientType: AdSourceType = .ima,
        indexInQueue: UInt = 0,
        duration: TimeInterval,
        timeOffset: TimeInterval,
        skipOffset: TimeInterval = 1,
        position: String = "0",
        // swiftlint:disable identifier_name
        ad: Ad,
        // swiftlint:enable identifier_name
        companionAds: [CompanionAd] = []
    ) {
        self.companionAds = companionAds

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
