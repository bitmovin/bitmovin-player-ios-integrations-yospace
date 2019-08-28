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
    var timedMetadataDictionary = Dictionary<Date,Bool>()
    
    init(player: BitmovinYospacePlayer) {
        super.init()
        self.player = player
        self.player?.add(listener: self)
    }

    func trackEmsg(_ event: MetadataEvent) {
        var mediaId = ""
        var nextInf = 0.0

        guard let dateRangeMetadata: DaterangeMetadata = event.metadata as? DaterangeMetadata else {
            return
        }
        
        if ( timedMetadataDictionary[dateRangeMetadata.startDate] != nil) {
            NSLog("[DateRangeEmitter] - duplicate metadata received")
            return
        }
        
        timedMetadataDictionary[dateRangeMetadata.startDate] = true;

        for entry: MetadataEntry in dateRangeMetadata.entries where entry.metadataType == BMPMetadataType.daterange {
            guard let entry = entry as? AVMetadataItem else {
                continue
            }

            guard let key = entry.key, let value = entry.stringValue else {
                continue
            }
            print("Key: \(key) - \(value)")

            switch key.description {
            case "X-COM-YOSPACE-YMID":
                mediaId = value
            case "X-COM-YOSPACE-NEXTINF":
                nextInf = Double(value) ?? 0.0
            default:
                continue
            }
        }

        guard let endDate = dateRangeMetadata.endDate, let player = self.player else {
            return
        }

        let duration: Double = endDate.timeIntervalSince1970 - dateRangeMetadata.startDate.timeIntervalSince1970
        var currentTime =  player.currentTimeWithAds()

        NSLog("[DateRangeEmitter] - handling daterange mediaId=\(mediaId) duration=\(duration) currentTime=\(currentTime)")

        let startMetdata = YSTimedMetadata()
        startMetdata.mediaId = mediaId
        startMetdata.type = "S"
        startMetdata.segmentCount = 1
        startMetdata.segmentNumber = 1
        startMetdata.offset = 0.1
        startMetdata.timestamp = dateRangeMetadata.startDate.addingTimeInterval(0.1)
        currentTime += 0.1
        let interval = 2.0
        let startEvent = DateRangeEvent(time: currentTime, metadata: startMetdata)
        timedMetadataEvents.append(startEvent)

        var iterator = 0.1
        while iterator < duration {
            let metadata = YSTimedMetadata()
            metadata.mediaId = mediaId
            metadata.type = "M"
            metadata.segmentCount = 1
            metadata.segmentNumber = 1
            iterator += interval
            metadata.offset = iterator
            metadata.timestamp = dateRangeMetadata.startDate.addingTimeInterval(iterator)
            let dateRangeEvent = DateRangeEvent(time: currentTime + iterator, metadata: metadata)
            timedMetadataEvents.append(dateRangeEvent)
        }

        let endMetadata = YSTimedMetadata()
        endMetadata.mediaId = mediaId
        endMetadata.type = "E"
        endMetadata.segmentCount = 1
        endMetadata.segmentNumber = 1
        endMetadata.timestamp = endDate.addingTimeInterval(-0.1);
        let endEvent = DateRangeEvent(time: currentTime + duration - 0.1, metadata: endMetadata)
        timedMetadataEvents.append(endEvent)
    
        NSLog("[DateRangeEmitter] TimedMetadataEvents - \(timedMetadataEvents.map{$0.time})" )
    
    }
}

extension DateRangeEmitter: PlayerListener {
    public func onTimeChanged(_ event: TimeChangedEvent) {
        guard let nextEvent = timedMetadataEvents.first else {
            return
        }
        NSLog("[DateRangeEmitter] - currentTime=\(event.currentTime) nextEventTime=\(nextEvent.time)")

        if event.currentTime > nextEvent.time {
            timedMetadataEvents.remove(at: 0)
            let yoMetadata = nextEvent.metadata
            //swiftlint:disable
            NSLog("[DateRangeEmitter] - Sending YoMetada: mid=\(yoMetadata.mediaId) type=\(yoMetadata.type) tD=\(yoMetadata.timestamp) tN=\(yoMetadata.timestamp.timeIntervalSince1970) sN=\(yoMetadata.segmentNumber) sC=\(yoMetadata.segmentCount) o=\(yoMetadata.offset)")
            //swiftlint:enable
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
        NSLog("[DateRangeEmitter] - onAdStarted \(self.player?.isAd)")
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("[DateRangeEmitter] - onAdFinished \(self.player?.isAd)")
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("[DateRangeEmitter] - onAdBreakFinished")
    }
    

}
