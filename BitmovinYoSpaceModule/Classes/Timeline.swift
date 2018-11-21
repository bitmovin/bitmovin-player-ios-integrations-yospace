//
//  YopsaceTimeline.swift
//  Pods
//
//  Created by Cory Zachman on 11/20/18.
//

import Foundation
import Yospace

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

class Timeline {
    var entrys: [TimelineEntry] = []
    var adBreaks: [YSAdBreak]

    init (adBreaks: [YSAdBreak]) {
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

    public func relativeToAbsolute(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = entrys.filter {$0.relativeStart < time}.reduce(0) { $0 + $1.duration }
        let absoluteTime: TimeInterval = time + passedAdBreakDurations
        return absoluteTime
    }

    public func absoluteToRelative(time: TimeInterval) -> TimeInterval {
        let passedAdBreakDurations = adBreaks.filter {$0.adBreakEnd() < time}.reduce(0) { $0 + $1.adBreakDuration() }

        //Check if we are in an ad break
        let currentAdBreaks = adBreaks.filter {$0.adBreakStart() < time}.filter {$0.adBreakEnd() > time}
        for currentAdBreak: YSAdBreak in currentAdBreaks {
            return currentAdBreak.adBreakStart() - passedAdBreakDurations
        }

        return time - passedAdBreakDurations
    }

}
