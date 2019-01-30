//
//  YopsaceTimeline.swift
//  Pods
//
//  Created by Cory Zachman on 11/20/18.
//

import Foundation
import Yospace
import BitmovinPlayer

enum TimelineEntryType {
    case adBreak
    case content
}

class TimelineEntry {
    init() {
    }
    var type: TimelineEntryType = .adBreak
    var relativeStart: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    var absoluteStart: TimeInterval = 0.0
    var absoluteEnd: TimeInterval = 0.0
}

public class Timeline: CustomDebugStringConvertible {
    var entrys: [TimelineEntry] = []
    private var adBreaks: [YSAdBreak]
    
    public init (adBreaks: [YSAdBreak]) {
        self.adBreaks = adBreaks
        let sorted: [YSAdBreak] = adBreaks.sorted { $0.adBreakStart() < $1.adBreakStart() }
        var count: Double = 0
        for adBreak in sorted {
            let timelineEntry: TimelineEntry = TimelineEntry()
            timelineEntry.absoluteStart = adBreak.adBreakStart()
            timelineEntry.duration = adBreak.adBreakDuration()
            timelineEntry.absoluteEnd = adBreak.adBreakEnd()
            timelineEntry.type = .adBreak
            timelineEntry.relativeStart = adBreak.adBreakStart() - count
            count += adBreak.adBreakDuration()
            entrys.append(timelineEntry)
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
        if let currentAd = currentAdBreak(time: time) {
            return time - currentAd.adBreakStart()
        } else {
            return time
        }
    }

    public func absoluteToRelative(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = adBreaks.filter {$0.adBreakEnd() < time}.reduce(0) { $0 + $1.adBreakDuration() }

        //Check if we are in an ad break, the relative time if you are in an ad break is equal to the ad breaks start time
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return time - passedAdBreakDurations
        }

        return currentAdBreak.adBreakStart() - passedAdBreakDurations

    }

    func currentAdBreak(time: TimeInterval) -> YSAdBreak? {
        return adBreaks.filter {$0.adBreakStart() < time}.filter {$0.adBreakEnd() > time}.first
    }

    func currentAd(time: TimeInterval) -> YSAdvert? {
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return nil
        }

        guard let ads = currentAdBreak.adverts() as? [YSAdvert] else {
            return nil
        }

        return ads.filter {$0.advertStart() < time}.filter {$0.advertEnd() > time}.first
    }

}
