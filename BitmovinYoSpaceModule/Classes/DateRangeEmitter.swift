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
    
    // MARK: - Properties
    
    weak var player: BitmovinYospacePlayer?
    var timedMetadataEvents: [TimedMetadataEvent] = []
    var processedDaterangeMetadata: [String: Date] = [:]
    var initialPDT: Date = Date()
    var deviceOffsetFromPDT: TimeInterval = 0
    let adEventOffset = 0.1 // Offset from the start and end of the ad that we will send the S and E event
    let mEventInterval = 2.0 // Interval at which we will send M event
    
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
    
    // MARK: - Init

    init(player: BitmovinYospacePlayer) {
        super.init()
        self.player = player
        self.player?.add(listener: self)
    }
    
    // MARK: - Deinit
    
    func reset() {
        timedMetadataEvents = []
        processedDaterangeMetadata = [String: Date]()
    }
    
    // MARK: - Emitter

    func trackEmsg(_ event: MetadataEvent) {
        guard let dateRangeMetadata = event.metadata as? DaterangeMetadata else {
            return
        }

        let mediaId = dateRangeMetadata.parseMediaId()
        let previousMetadataDate = processedDaterangeMetadata[mediaId]

        // Ignore date if less than 10 seconds apart from previous
        if let date = previousMetadataDate, abs(date - dateRangeMetadata.startDate) < 10 {
            BitLog.d("Duplicate metadata received - \(dateRangeMetadata.startDate)")
            return
        }

        processedDaterangeMetadata[mediaId] = dateRangeMetadata.startDate

        guard let endDate = dateRangeMetadata.endDate, let player = self.player else {
            return
        }

        // Generate Yospace timed metadata events based on EXT-X-DATERANGE tag just processed
        generateEventsForDateRange(
            mediaId: mediaId,
            startDate: dateRangeMetadata.startDate,
            endDate: endDate,
            player: player
        )
    }

    private func generateEventsForDateRange(mediaId: String, startDate: Date, endDate: Date, player: BitmovinYospacePlayer) {
        let duration = Double(endDate - startDate)
        var currentTime = player.currentTimeWithAds()
        let startWallclock = startDate.timeIntervalSince1970 + deviceOffsetFromPDT + adEventOffset
                
        BitLog.d("Generating Yospace TimedMetadataEvents: mediaId=\(mediaId), duration=\(duration), currentTime=\(currentTime), startDate=\(startDate)")
        
        // Generate S event
        let sEvent = YSTimedMetadata()
        sEvent.mediaId = mediaId
        sEvent.type = "S"
        sEvent.segmentCount = 1
        sEvent.segmentNumber = 1
        sEvent.offset = adEventOffset
        sEvent.timestamp = Date(timeIntervalSince1970: startWallclock)
        currentTime += adEventOffset
        
        let sTimedMetadataEvent = TimedMetadataEvent(time: currentTime, metadata: sEvent)
        fireMetadataParsedEvent(event: sTimedMetadataEvent)
        timedMetadataEvents.append(sTimedMetadataEvent)
        
        // Generate M events
        var offset = adEventOffset + mEventInterval
        while offset < duration {
            let mEvent = YSTimedMetadata()
            mEvent.mediaId = mediaId
            mEvent.type = "M"
            mEvent.segmentCount = 1
            mEvent.segmentNumber = 1
            mEvent.offset = offset
            mEvent.timestamp = Date(timeIntervalSince1970: startWallclock + offset)
            
            let mTimedMetadataEvent = TimedMetadataEvent(time: currentTime + offset, metadata: mEvent)
            fireMetadataParsedEvent(event: mTimedMetadataEvent)
            timedMetadataEvents.append(mTimedMetadataEvent)
            
            offset += mEventInterval
        }

        // Generate E event
        let eEvent = YSTimedMetadata()
        eEvent.mediaId = mediaId
        eEvent.type = "E"
        eEvent.segmentCount = 1
        eEvent.segmentNumber = 1
        eEvent.timestamp = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 + deviceOffsetFromPDT - adEventOffset)
        eEvent.offset = duration - adEventOffset
        
        let eTimedMetadataEvent = TimedMetadataEvent(time: currentTime + duration - adEventOffset, metadata: eEvent)
        fireMetadataParsedEvent(event: eTimedMetadataEvent)
        timedMetadataEvents.append(eTimedMetadataEvent)
    
        BitLog.d("Generated TimedMetadataEvents: \(timedMetadataEvents.map { $0.metadata.timestamp })" )
    }
    
    func fireMetadataParsedEvent(event: TimedMetadataEvent) {
        let entries = [event.toYospaceId3MetadataEntry()]
        let metadata = Id3Metadata(entries: entries, startTime: event.time)
        let event = MetadataParsedEvent(metadata: metadata, type: .ID3)
        player?.listeners.forEach { $0.onMetadataParsed?(event) }
    }
    
    func fireMetadataEvent(event: TimedMetadataEvent) {
        let entries = [event.toYospaceId3MetadataEntry()]
        let metadata = Id3Metadata(entries: entries, startTime: event.time)
        let event = MetadataEvent(metadata: metadata, type: .ID3)
        player?.listeners.forEach { $0.onMetadata?(event) }
    }
}

// MARK: - PlayerListener

extension DateRangeEmitter: PlayerListener {
    
    public func onReady(_ event: ReadyEvent) {
        guard let player = player else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        initialPDT = Date(timeIntervalSince1970: player.currentTimeWithAds())
        deviceOffsetFromPDT = Date().timeIntervalSince(initialPDT)
        let relativePlayheadTime = player.currentTimeWithAds() - seekableRange.start
        BitLog.d("initialPDT=\(dateFormatter.string(from: initialPDT)) deviceOffsetPDT=\(deviceOffsetFromPDT) relativeCurrentTime=\(relativePlayheadTime)")
    }
    
    public func onTimeChanged(_ event: TimeChangedEvent) {
        guard let nextEvent = timedMetadataEvents.first else {
            return
        }

        let currentTime = player?.currentTimeWithAds() ?? event.currentTime

        // Send metadata event if playhead is within 1 second of metadata time
        if currentTime - nextEvent.time >= -1 {
            timedMetadataEvents.removeFirst(1)
            let metadata = nextEvent.metadata
            
            // swiftlint:disable line_length
            BitLog.d("Sending metadata: currentDate=\(NSDate().timeIntervalSince1970), playerTime=\(currentTime), eventTime=\(nextEvent.time), metadataTime=\(metadata.timestamp.timeIntervalSince1970), id=\(metadata.mediaId), type=\(metadata.type), segment=\(metadata.segmentNumber), segmentCount=\(metadata.segmentCount), offset=\(metadata.offset)")
            // swiftlint:enable line_length
            
            player?.notify(dictionary: [kYoMetadataKey: metadata], name: YoTimedMetadataNotification)
            fireMetadataEvent(event: nextEvent)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        reset()
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        reset()
    }
    
    func onError(_ event: ErrorEvent) {
        reset()
    }
}

// MARK: - DaterangeMetadata Extensions

extension DaterangeMetadata {
    func parseMediaId() -> String {
        return entries.filter { $0.metadataType == .daterange }
            .compactMap { $0 as? AVMetadataItem }
            .last(where: { $0.key?.description == "X-COM-YOSPACE-YMID" })?
            .stringValue ?? ""
    }
}

// MARK: - Date Extensions

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

// MARK: - TimedMetadataEvent Extensions

extension TimedMetadataEvent {
    func toYospaceId3MetadataEntry() -> YospaceId3MetadataEntry {
        return YospaceId3MetadataEntry(
            mediaId: metadata.mediaId,
            type: metadata.type,
            segmentCount: metadata.segmentCount,
            segmentNumber: metadata.segmentNumber,
            offset: metadata.offset,
            timestamp: metadata.timestamp
        )
    }
}
