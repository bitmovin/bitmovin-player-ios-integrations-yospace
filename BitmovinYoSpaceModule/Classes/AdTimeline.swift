//
//  YopsaceTimeline.swift
//  Pods
//
//  Created by Cory Zachman on 11/20/18.
//

import Foundation
import Yospace
import BitmovinPlayer

public class AdBreak: CustomDebugStringConvertible {
    public private(set) var relativeStart: TimeInterval = 0.0
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var absoluteStart: TimeInterval = 0.0
    public private(set) var absoluteEnd: TimeInterval = 0.0
    public private(set) var identifier: String = "unknown"
    public private(set) var ads: [Ad] = []

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
    }

    init(ysAdBreak: YSAdBreak) {
        self.identifier = ysAdBreak.adBreakIdentifier()
        self.absoluteStart = ysAdBreak.adBreakStart()
        self.absoluteEnd = ysAdBreak.adBreakEnd()
        self.duration = ysAdBreak.adBreakDuration()
        self.relativeStart = ysAdBreak.adBreakStart()
        
        for advertisement in ysAdBreak.adverts() {
            if let advert: YSAdvert = advertisement as? YSAdvert {
                let newAd: Ad = Ad(ysAd: advert, relativeStart: self.relativeStart)
                self.appendAd(ad: newAd)
            }
        }
    }

    //swiftlint:disable identifier_name
    func appendAd(ad: Ad) {
        self.ads.append(ad)
    }
    //swiftlint:enable identifier_name

    public var debugDescription: String {
        return "id=\(self.identifier) absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd) ads=\(ads.map {$0.identifier})"
    }

}

//swiftlint:disable type_name
public class Ad: CustomDebugStringConvertible {
    public private(set) var relativeStart: TimeInterval = 0.0
    public private(set) var identifier: String = "unknown"
    public private(set) var duration: TimeInterval = 0.0
    public private(set) var hasInteractiveUnit = false
    public private(set) var absoluteStart: TimeInterval = 0.0
    public private(set) var absoluteEnd: TimeInterval = 0.0

    init(identifier: String, absoluteStart: TimeInterval, absoluteEnd: TimeInterval, duration: TimeInterval, relativeStart: TimeInterval, hasInteractiveUnit: Bool) {
        self.identifier = identifier
        self.absoluteStart = absoluteStart
        self.absoluteEnd = absoluteEnd
        self.duration = duration
        self.relativeStart = relativeStart
        self.hasInteractiveUnit = hasInteractiveUnit
    }
    
    init (ysAd: YSAdvert, relativeStart: TimeInterval) {
        self.identifier = ysAd.advertIdentifier()
        self.absoluteStart = ysAd.advertStart()
        self.absoluteEnd = ysAd.advertEnd()
        self.duration = ysAd.advertDuration()
        self.relativeStart = relativeStart
        self.hasInteractiveUnit = ysAd.hasLinearInteractiveUnit()
    }

    public var debugDescription: String {
        return "id=\(self.identifier) absoluteStart=\(self.absoluteStart) absoluteEnd=\(self.absoluteEnd)"
    }

}
//swiftlint:enable type_name

public class AdTimeline: CustomDebugStringConvertible {
    public private(set) var adBreaks: [AdBreak] = []

    public init (breaks: [YSAdBreak]) {
        let sorted: [YSAdBreak] = breaks.sorted { $0.adBreakStart() < $1.adBreakStart() }
        var count: Double = 0
        for adBreak in sorted {
            let adBreakEntry: AdBreak = AdBreak(identifier: adBreak.adBreakIdentifier(),
                                                absoluteStart: adBreak.adBreakStart(),
                                                absoluteEnd: adBreak.adBreakEnd(),
                                                duration: adBreak.adBreakDuration(),
                                                relativeStart: adBreak.adBreakStart() - count)

            for advertisement in adBreak.adverts() {
                if let advert: YSAdvert = advertisement as? YSAdvert {
                    let newAd: Ad = Ad(identifier: advert.advertIdentifier(),
                                       absoluteStart: advert.advertStart(),
                                       absoluteEnd: advert.advertEnd(),
                                       duration: advert.advertDuration(),
                                       relativeStart: adBreakEntry.relativeStart,
                                       hasInteractiveUnit: advert.hasLinearInteractiveUnit())
                    adBreakEntry.appendAd(ad: newAd)
                }
            }
            count += adBreak.adBreakDuration()
            adBreaks.append(adBreakEntry)
        }
    }

    public var debugDescription: String {
        var str = "Timeline has \(adBreaks.count) ad breaks. "
        for entry in adBreaks {
            str += "[Relative Start: \(entry.relativeStart) Duration - \(entry.duration) Absolute: \(entry.absoluteStart) - \(entry.absoluteEnd) ]"
        }
        return str
    }

    public func relativeToAbsolute(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = adBreaks.filter {$0.relativeStart < time}.reduce(0) { $0 + $1.duration }
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
        let passedAdBreakDurations = adBreaks.filter {$0.absoluteEnd < time}.reduce(0) { $0 + $1.duration}

        //Check if we are in an ad break, the relative time if you are in an ad break is equal to the ad breaks start time
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return time - passedAdBreakDurations
        }

        return currentAdBreak.absoluteStart - passedAdBreakDurations

    }

    func currentAdBreak(time: TimeInterval) -> AdBreak? {
        return adBreaks.filter {$0.absoluteStart < time}.filter {$0.absoluteEnd > time}.first
    }

    func currentAd(time: TimeInterval) -> Ad? {
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return nil
        }

        return currentAdBreak.ads.filter {$0.absoluteStart < time}.filter {$0.absoluteEnd > time}.first
    }

}
