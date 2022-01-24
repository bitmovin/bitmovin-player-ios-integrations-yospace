//
//  TrueXAdStartedEvent.swift
//  Pods
//
//  Created by Cory Zachman on 9/20/19.
//

import Foundation
import BitmovinPlayer
import Yospace

public class YospaceAdStartedEvent: AdStartedEvent {
    public var companionAds: [CompanionAd]

    init(
        clickThroughUrl: URL?,
        clientType: BMPAdSourceType = .IMA,
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
