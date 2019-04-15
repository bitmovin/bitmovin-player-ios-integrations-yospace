//
//  YopsaceTimeline.swift
//  Pods
//
//  Created by Cory Zachman on 11/20/18.
//

import Foundation
import Yospace
import BitmovinPlayer

public class AdBreak {
    init() {
    }
    var relativeStart: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    var absoluteStart: TimeInterval = 0.0
    var absoluteEnd: TimeInterval = 0.0
    var identifier: String = "unknown"
    var ads: [Ad] = []
}

//swiftlint:disable type_name
public class Ad {
    init() {
    }
    var position: TimeInterval = 0.0
    var identifier: String = "unknown"
    var duration: TimeInterval = 0.0
    var hasInteractiveUnit = false
    var absoluteStart: TimeInterval = 0.0
    var absoluteEnd: TimeInterval = 0.0
}
//swiftlint:enable type_name

public class AdTimeline: CustomDebugStringConvertible {
    var entrys: [AdBreak] = []

    public init (adBreaks: [YSAdBreak]) {
        let sorted: [YSAdBreak] = adBreaks.sorted { $0.adBreakStart() < $1.adBreakStart() }
        var count: Double = 0
        for adBreak in sorted {
            let adBreakEntry: AdBreak = AdBreak()
            adBreakEntry.identifier = adBreak.adBreakIdentifier()
            adBreakEntry.absoluteStart = adBreak.adBreakStart()
            adBreakEntry.duration = adBreak.adBreakDuration()
            adBreakEntry.absoluteEnd = adBreak.adBreakEnd()
            adBreakEntry.relativeStart = adBreak.adBreakStart() - count
            for advertisement in adBreak.adverts() {
                if let advert: YSAdvert = advertisement as? YSAdvert {
                    let newAd: Ad = Ad()
                    newAd.identifier = advert.advertIdentifier()
                    newAd.position = adBreakEntry.relativeStart
                    newAd.absoluteStart = advert.advertStart()
                    newAd.absoluteEnd = advert.advertEnd()
                    newAd.duration = advert.advertDuration()
                    newAd.hasInteractiveUnit = advert.hasLinearInteractiveUnit()
                    adBreakEntry.ads.append(newAd)
                }
            }
            count += adBreak.adBreakDuration()
            entrys.append(adBreakEntry)
        }
    }

    public var debugDescription: String {
        var str = "Timeline has \(entrys.count) ad breaks. "
        for entry in entrys {
            str += "[Relative Start: \(entry.relativeStart) Duration - \(entry.duration) Absolute: \(entry.absoluteStart) - \(entry.absoluteEnd) ]"
        }
        return str
    }

    public func relativeToAbsolute(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = entrys.filter {$0.relativeStart < time}.reduce(0) { $0 + $1.duration }
        let absoluteTime: TimeInterval = time + passedAdBreakDurations
        return absoluteTime
    }

    public func adTime(time: TimeInterval) -> TimeInterval {
        if let currentAd = currentAd(time: time) {
            return time - currentAd.absoluteStart
        } else {
            return time
        }
    }

    public func absoluteToRelative(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = entrys.filter {$0.absoluteEnd < time}.reduce(0) { $0 + $1.duration}

        //Check if we are in an ad break, the relative time if you are in an ad break is equal to the ad breaks start time
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return time - passedAdBreakDurations
        }

        return currentAdBreak.absoluteStart - passedAdBreakDurations

    }

    func currentAdBreak(time: TimeInterval) -> AdBreak? {
        return entrys.filter {$0.absoluteStart < time}.filter {$0.absoluteEnd > time}.first
    }

    func currentAd(time: TimeInterval) -> Ad? {
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return nil
        }

        return currentAdBreak.ads.filter {$0.absoluteStart < time}.filter {$0.absoluteEnd > time}.first
    }

}
