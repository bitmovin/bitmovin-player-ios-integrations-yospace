//
//  DateRangeEmitter.swift
//  Pods
//
//  Created by Cory Zachman on 8/28/19.
//

import Foundation
import BitmovinPlayer
import Yospace

struct DateRangeEvent {
    let time: TimeInterval
    let metadata: YSTimedMetadata
}

class DateRangeEmitter: NSObject {
    weak var player: BitmovinYospacePlayer?
    var timedMetadataEvents: [DateRangeEvent] = []
    var timedMetadataDictionary = [String: Date]()
    var pdt: Date = Date()
    var startOffset: TimeInterval = 0
    var startPdt: Date = Date()

    init(player: BitmovinYospacePlayer) {
        super.init()
        self.player = player
        self.player?.add(listener: self)
    }

    func trackEmsg(_ event: MetadataEvent) {
        var mediaId = ""

        guard let dateRangeMetadata: DaterangeMetadata = event.metadata as? DaterangeMetadata else {
            return
        }

        for entry: MetadataEntry in dateRangeMetadata.entries where entry.metadataType == BMPMetadataType.daterange {
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

        let previousMetadataDate: Date? = timedMetadataDictionary[mediaId];
        
        if  let date = previousMetadataDate, date.timeIntervalSince(dateRangeMetadata.startDate) < 15.0 {
            NSLog("[DateRangeEmitter] - duplicate metadata received")
            return
        }

        timedMetadataDictionary[mediaId] = dateRangeMetadata.startDate

        guard let endDate = dateRangeMetadata.endDate, let player = self.player else {
            return
        }

        let offset = 0.1
        let duration: Double = endDate.timeIntervalSince1970 - dateRangeMetadata.startDate.timeIntervalSince1970
        var currentTime =  player.currentTimeWithAds()
        let pdtOffset = dateRangeMetadata.startDate.timeIntervalSince(startPdt)
        let startWallclock = dateRangeMetadata.startDate.timeIntervalSince1970 + startOffset + offset
        let midInterval = 2.0

        NSLog("[DateRangeEmitter] - handling daterange mediaId=\(mediaId) duration=\(duration) currentTime=\(currentTime) pdtOffset=\(pdtOffset) startDate=\(dateRangeMetadata.startDate)")

        let startMetdata = YSTimedMetadata()
        startMetdata.mediaId = mediaId
        startMetdata.type = "S"
        startMetdata.segmentCount = 1
        startMetdata.segmentNumber = 1
        startMetdata.offset = offset
        startMetdata.timestamp = Date(timeIntervalSince1970: startWallclock)
        currentTime += offset
        let startEvent = DateRangeEvent(time: currentTime, metadata: startMetdata)
        timedMetadataEvents.append(startEvent)

        var iterator = 0.1 + midInterval
        while iterator < duration {
            let metadata = YSTimedMetadata()
            metadata.mediaId = mediaId
            metadata.type = "M"
            metadata.segmentCount = 1
            metadata.segmentNumber = 1
            metadata.offset = iterator
            metadata.timestamp = Date(timeIntervalSince1970: startWallclock + iterator)
            let dateRangeEvent = DateRangeEvent(time: currentTime + iterator, metadata: metadata)
            timedMetadataEvents.append(dateRangeEvent)
            iterator += midInterval
        }

        let endMetadata = YSTimedMetadata()
        endMetadata.mediaId = mediaId
        endMetadata.type = "E"
        endMetadata.segmentCount = 1
        endMetadata.segmentNumber = 1
        endMetadata.timestamp = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 + startOffset - offset)
        endMetadata.offset = duration - offset
        let endEvent = DateRangeEvent(time: currentTime + duration - offset, metadata: endMetadata)
        timedMetadataEvents.append(endEvent)

        NSLog("[DateRangeEmitter] TimedMetadataEvents - \(timedMetadataEvents.map {$0.metadata.timestamp})" )
    }
}

extension DateRangeEmitter: PlayerListener {
    public func onTimeChanged(_ event: TimeChangedEvent) {
        guard let nextEvent = timedMetadataEvents.first else {
            return
        }

        let currentTime = player?.currentTimeWithAds() ?? event.currentTime

//        NSLog("[DateRangeEmitter] - time=\(currentTime)")

        if (currentTime - nextEvent.time) >= -1 {
            timedMetadataEvents.removeFirst(1)
            let yoMetadata = nextEvent.metadata
            // swiftlint:disable line_length
            NSLog("[DateRangeEmitter] - Sending YoMetada: currentDate=\(NSDate().timeIntervalSince1970) currentTime=\(currentTime) eventTime=\(nextEvent.time) mid=\(yoMetadata.mediaId) type=\(yoMetadata.type) tD=\(yoMetadata.timestamp) tN=\(yoMetadata.timestamp.timeIntervalSince1970) sN=\(yoMetadata.segmentNumber) sC=\(yoMetadata.segmentCount) o=\(yoMetadata.offset)")
            // swiftlint:enable line_length
            self.player?.notify(dictionary: [kYoMetadataKey: yoMetadata], name: YoTimedMetadataNotification)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        timedMetadataEvents = []
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        timedMetadataEvents = []
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
        pdt = Date(timeIntervalSince1970: player.currentTimeWithAds())
        startOffset = Date().timeIntervalSince(pdt)
        let time = player.currentTimeWithAds() - player.seekableRange.start
        startPdt = self.pdt.addingTimeInterval(-1 * time)
        NSLog("[DateRangeEmitter] pdt=\(dateFormatter.string(from: pdt)) startOffset=\(startOffset) startPdt=\(dateFormatter.string(from: startPdt)) time=\(time)")
    }

}
