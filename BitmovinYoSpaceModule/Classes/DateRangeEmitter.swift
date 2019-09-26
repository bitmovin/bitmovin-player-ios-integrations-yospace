//
//  DateRangeEmitter.swift
//  Pods
//
//  Created by Cory Zachman on 8/28/19.
//

import Foundation
import BitmovinPlayer
import Yospace

struct TimedMetadataEvent {
    let time: TimeInterval
    let metadata: YSTimedMetadata
}

class DateRangeEmitter: NSObject {
    weak var player: BitmovinYospacePlayer?
    var timedMetadataEvents: [TimedMetadataEvent] = []
    var processedDaterangeMetadata: [String: Date] = [:]
    var initialPDT: Date = Date()
    var deviceOffsetFromPDT: TimeInterval = 0
    let adEventOffset = 0.1 // Offset from the start and end of the ad that we will send the S and E event
    let mEventInterval = 2.0 //Interval at which we will send M event
    var seekableRange: TimeRange {
        guard let player = player else {
            return TimeRange(start: 0, end: 0)
        }
        if player.isLive {
            let currentTime = player.currentTimeWithAds()
            let timeShift = player.timeShift
            let maxTimeShift = player.maxTimeShift
            let start = currentTime + maxTimeShift - timeShift
            let end = currentTime - timeShift
            return TimeRange(start: start, end: end)
        } else {
            return TimeRange(start: 0, end: player.duration)
        }
    }

    init(player: BitmovinYospacePlayer) {
        super.init()
        self.player = player
        self.player?.add(listener: self)
    }

    func trackEmsg(_ event: MetadataEvent) {
        guard let dateRangeMetadata: DaterangeMetadata = event.metadata as? DaterangeMetadata else {
            return
        }

        let mediaId = parseMediaId(daterangeMetadata: dateRangeMetadata)

        let previousMetadataDate: Date? = processedDaterangeMetadata[mediaId]

        /**
         * Compare the date between the metadata I have seen and the current metadata I received. If this is less than 15 seconds
         * it probably is a duplicate
         */
        if  let date = previousMetadataDate, dateRangeMetadata.startDate.timeIntervalSince(date) < 15.0 {
            BitmovinLogger.d(message: "[DateRangeEmitter] - duplicate metadata received - \(mediaId) \(dateRangeMetadata.startDate)")
            return
        }

        processedDaterangeMetadata[mediaId] = dateRangeMetadata.startDate

        guard let endDate = dateRangeMetadata.endDate, let player = self.player else {
            return
        }

        generateEventsForDateRange(mediaId: mediaId, startDate: dateRangeMetadata.startDate, endDate: endDate, player: player)
    }

    /**
     Parse the mediaId our of the DaterangeMetadata
    */
    private func parseMediaId(daterangeMetadata: DaterangeMetadata) -> String {
        var mediaId = ""
        for entry: MetadataEntry in daterangeMetadata.entries where entry.metadataType == BMPMetadataType.daterange {
            guard let entry = entry as? AVMetadataItem else {
                continue
            }

            guard let key = entry.key, let value = entry.stringValue else {
                continue
            }

            switch key.description {
            case "X-COM-YOSPACE-YMID":
                mediaId = value
            default:
                continue
            }
        }
        return mediaId
    }

    /**
     Generate all of our YSTimedMetadata events based on the EXT-X-DATERANGE tag that we just processed
    */
    private func generateEventsForDateRange(mediaId: String, startDate: Date, endDate: Date, player: BitmovinYospacePlayer) {
        let duration: Double = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        var currentTime =  player.currentTimeWithAds()
        let startWallclock = startDate.timeIntervalSince1970 + deviceOffsetFromPDT + adEventOffset

        BitmovinLogger.d(message: "[DateRangeEmitter] - handling daterange mediaId=\(mediaId) duration=\(duration) currentTime=\(currentTime) startDate=\(startDate)")

        let startMetdata = YSTimedMetadata()
        startMetdata.mediaId = mediaId
        startMetdata.type = "S"
        startMetdata.segmentCount = 1
        startMetdata.segmentNumber = 1
        startMetdata.offset = adEventOffset
        startMetdata.timestamp = Date(timeIntervalSince1970: startWallclock)
        currentTime += adEventOffset
        let startTimedMetadataEvent = TimedMetadataEvent(time: currentTime, metadata: startMetdata)
        timedMetadataEvents.append(startTimedMetadataEvent)

        var iterator = adEventOffset + mEventInterval
        while iterator < duration {
            let  midMetadata = YSTimedMetadata()
            midMetadata.mediaId = mediaId
            midMetadata.type = "M"
            midMetadata.segmentCount = 1
            midMetadata.segmentNumber = 1
            midMetadata.offset = iterator
            midMetadata.timestamp = Date(timeIntervalSince1970: startWallclock + iterator)
            let timedMetadataEvent = TimedMetadataEvent(time: currentTime + iterator, metadata: midMetadata)
            timedMetadataEvents.append(timedMetadataEvent)
            iterator += mEventInterval
        }

        let endMetadata = YSTimedMetadata()
        endMetadata.mediaId = mediaId
        endMetadata.type = "E"
        endMetadata.segmentCount = 1
        endMetadata.segmentNumber = 1
        endMetadata.timestamp = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 + deviceOffsetFromPDT - adEventOffset)
        endMetadata.offset = duration - adEventOffset
        let endTimedMetadataEvent = TimedMetadataEvent(time: currentTime + duration - adEventOffset, metadata: endMetadata)
        timedMetadataEvents.append(endTimedMetadataEvent)

        BitmovinLogger.d(message: "[DateRangeEmitter] TimedMetadataEvents - \(timedMetadataEvents.map {$0.metadata.timestamp})" )
    }
}

extension DateRangeEmitter: PlayerListener {
    public func onTimeChanged(_ event: TimeChangedEvent) {

        //If we have no TimedMetadataEvents to send, return
        guard let nextEvent = timedMetadataEvents.first else {
            return
        }

        let currentTime = player?.currentTimeWithAds() ?? event.currentTime

        // If our players currentTime is passed the nextEvents time, send a YSTimedMetadata event and remove it from our list
        if (currentTime - nextEvent.time) >= -1 {
            timedMetadataEvents.removeFirst(1)
            let yoMetadata = nextEvent.metadata
            // swiftlint:disable line_length
            BitmovinLogger.d(message: "[DateRangeEmitter] - Sending YSTimedMetada: currentDate=\(NSDate().timeIntervalSince1970) currentTime=\(currentTime) eventTime=\(nextEvent.time) mid=\(yoMetadata.mediaId) type=\(yoMetadata.type) tD=\(yoMetadata.timestamp) tN=\(yoMetadata.timestamp.timeIntervalSince1970) sN=\(yoMetadata.segmentNumber) sC=\(yoMetadata.segmentCount) o=\(yoMetadata.offset)")
            // swiftlint:enable line_length
            self.player?.notify(dictionary: [kYoMetadataKey: yoMetadata], name: YoTimedMetadataNotification)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        timedMetadataEvents = []
        processedDaterangeMetadata = [String: Date]()
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        timedMetadataEvents = []
        processedDaterangeMetadata = [String: Date]()
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        BitmovinLogger.d(message: "[DateRangeEmitter] - onAdBreakStarted")
    }

    public func onAdStarted(_ event: AdStartedEvent) {
        BitmovinLogger.d(message: "[DateRangeEmitter] - onAdStarted")
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        BitmovinLogger.d(message: "[DateRangeEmitter] - onAdFinished")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        BitmovinLogger.d(message: "[DateRangeEmitter] - onAdBreakFinished")
    }

    public func onReady(_ event: ReadyEvent) {
        BitmovinLogger.d(message: "[DateRangeEmitter] - onReady")
        guard let player = player else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        initialPDT = Date(timeIntervalSince1970: player.currentTimeWithAds())
        deviceOffsetFromPDT = Date().timeIntervalSince(initialPDT)
        let relativePlayheadTime = player.currentTimeWithAds() - seekableRange.start
        // swiftlint:disable line_length
        BitmovinLogger.d(message: "[DateRangeEmitter] initialPDT=\(dateFormatter.string(from: initialPDT)) deviceOffsetPDT=\(deviceOffsetFromPDT) relativeCurrentTime=\(relativePlayheadTime)")
        // swiftlint:enable line_length

    }

}
