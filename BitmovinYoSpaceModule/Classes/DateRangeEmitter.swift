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
    var processedDaterangeMetadata = [String: Date]()
    var initialPDT: Date = Date()
    var deviceOffsetFromPDT: TimeInterval = 0
    let adEventOffset = 0.1 // Offset from the start and end of the ad that we will send the S and E event
    let mEventInterval = 2.0 //Interval at which we will send M event

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

        if  let date = previousMetadataDate, dateRangeMetadata.startDate.timeIntervalSince(date) < 15.0 {
            NSLog("[DateRangeEmitter] - duplicate metadata received - \(mediaId) \(dateRangeMetadata.startDate)")
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

        NSLog("[DateRangeEmitter] - handling daterange mediaId=\(mediaId) duration=\(duration) currentTime=\(currentTime) startDate=\(startDate)")

        let startMetdata = YSTimedMetadata()
        startMetdata.mediaId = mediaId
        startMetdata.type = "S"
        startMetdata.segmentCount = 1
        startMetdata.segmentNumber = 1
        startMetdata.offset = adEventOffset
        startMetdata.timestamp = Date(timeIntervalSince1970: startWallclock)
        currentTime += adEventOffset
        let startEvent = TimedMetadataEvent(time: currentTime, metadata: startMetdata)
        timedMetadataEvents.append(startEvent)

        var iterator = 0.1 + mEventInterval
        while iterator < duration {
            let metadata = YSTimedMetadata()
            metadata.mediaId = mediaId
            metadata.type = "M"
            metadata.segmentCount = 1
            metadata.segmentNumber = 1
            metadata.offset = iterator
            metadata.timestamp = Date(timeIntervalSince1970: startWallclock + iterator)
            let dateRangeEvent = TimedMetadataEvent(time: currentTime + iterator, metadata: metadata)
            timedMetadataEvents.append(dateRangeEvent)
            iterator += mEventInterval
        }

        let endMetadata = YSTimedMetadata()
        endMetadata.mediaId = mediaId
        endMetadata.type = "E"
        endMetadata.segmentCount = 1
        endMetadata.segmentNumber = 1
        endMetadata.timestamp = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 + deviceOffsetFromPDT - adEventOffset)
        endMetadata.offset = duration - adEventOffset
        let endEvent = TimedMetadataEvent(time: currentTime + duration - adEventOffset, metadata: endMetadata)
        timedMetadataEvents.append(endEvent)

        NSLog("[DateRangeEmitter] TimedMetadataEvents - \(timedMetadataEvents.map {$0.metadata.timestamp})" )
    }
}

extension DateRangeEmitter: PlayerListener {
    public func onTimeChanged(_ event: TimeChangedEvent) {

        //If we have no TimedMetadataEvents to send, return
        guard let nextEvent = timedMetadataEvents.first else {
            return
        }

        let currentTime = player?.currentTimeWithAds() ?? event.currentTime

        // If our players currentTime is passed the nextEvents time, send a YSTimedMetadata event
        if (currentTime - nextEvent.time) >= -1 {
            timedMetadataEvents.removeFirst(1)
            let yoMetadata = nextEvent.metadata
            // swiftlint:disable line_length
            NSLog("[DateRangeEmitter] - Sending YSTimedMetada: currentDate=\(NSDate().timeIntervalSince1970) currentTime=\(currentTime) eventTime=\(nextEvent.time) mid=\(yoMetadata.mediaId) type=\(yoMetadata.type) tD=\(yoMetadata.timestamp) tN=\(yoMetadata.timestamp.timeIntervalSince1970) sN=\(yoMetadata.segmentNumber) sC=\(yoMetadata.segmentCount) o=\(yoMetadata.offset)")
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
        NSLog("[DateRangeEmitter] - onAdBreakStarted")
    }

    public func onAdStarted(_ event: AdStartedEvent) {
        NSLog("[DateRangeEmitter] - onAdStarted")
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("[DateRangeEmitter] - onAdFinished")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("[DateRangeEmitter] - onAdBreakFinished")
    }

    public func onReady(_ event: ReadyEvent) {
        NSLog("[DateRangeEmitter] - onReady")
        guard let player = player else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        initialPDT = Date(timeIntervalSince1970: player.currentTimeWithAds())
        deviceOffsetFromPDT = Date().timeIntervalSince(initialPDT)
        let relativePlayheadTime = player.currentTimeWithAds() - player.seekableRange.start
        NSLog("[DateRangeEmitter] pdt=\(dateFormatter.string(from: initialPDT)) startOffset=\(deviceOffsetFromPDT) time=\(relativePlayheadTime)")
    }

}
