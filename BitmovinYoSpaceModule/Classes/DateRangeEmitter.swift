//
//  DateRangeEmitter.swift
//  Pods
//
//  Created by Cory Zachman on 8/28/19.
//

import Foundation
import BitmovinPlayer
import YOAdManagement

struct TimedMetadataEvent {
    let time: TimeInterval
    let metadata: YOTimedMetadata
    
    // Part of the iOS time jump workaround, to account for jumps that could've occurred between generation and firing
    let rawTime: Double
    let normalizedTime: Double
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
    
    weak var playheadNormalizer: PlayheadNormalizer?
    
    var seekableRange: TimeRange {
        guard let player = player else {
            return TimeRange(start: 0, end: 0)
        }
        if player.isLive() {
            let currentTime = player.currentTimeWithAds()
            let timeShift = player.bitmovinPlayer().timeShift
            let maxTimeShift = player.bitmovinPlayer().maxTimeShift
            let start = currentTime + maxTimeShift - timeShift
            let end = currentTime - timeShift
            return TimeRange(start: start, end: end)
        } else {
            return TimeRange(start: 0, end: player.duration())
        }
    }

    // MARK: - Init

    init(player: BitmovinYospacePlayer, normalizer: PlayheadNormalizer? = nil) {
        super.init()
        self.player = player
        self.playheadNormalizer = normalizer
        
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
        
        // Upon receipt of timed metadata, inform the normalizer (if instantiated)
        // This will reset any active normalization, and switch modes to attempting to ensure all the following generated metadata is always fired at the proper intervals
        playheadNormalizer?.notifyDateRangeMetadataReceived()
        
        var currentTime: Double = {
            if let playheadNormalizer = playheadNormalizer {
                return playheadNormalizer.currentNormalizedTime()
            } else {
                return player.currentTimeWithAds()
            }
        }()
        let currentTimeAtStart = currentTime
        let rawTime = player.currentTimeWithAds()
        
        let startWallclock = startDate.timeIntervalSince1970 + deviceOffsetFromPDT + adEventOffset

        BitLog.d("Generating Yospace TimedMetadataEvents: mediaId=\(mediaId), duration=\(duration), currentTime=\(currentTime), startDate=\(startDate)")

        // Generate S event
        guard let sEvent = YOTimedMetadata.create(withMediaId: mediaId, sequence: "1:1", type: "S", offset: adEventOffset.description, playhead: startWallclock) else {
            BitLog.w("Failed to create TimedMetadataEvent: mediaId=\(mediaId), offset=\(adEventOffset), playhead=\(startWallclock)")
            return
        }
        currentTime += adEventOffset

        let sTimedMetadataEvent = TimedMetadataEvent(time: currentTime, metadata: sEvent, rawTime: rawTime, normalizedTime: currentTimeAtStart)
        fireMetadataParsedEvent(event: sTimedMetadataEvent)
        timedMetadataEvents.append(sTimedMetadataEvent)

        // Generate M events
        var offset = adEventOffset + mEventInterval
        while offset < duration {
            guard let mEvent = YOTimedMetadata.create(withMediaId: mediaId, sequence: "1:1", type: "M", offset: offset.description, playhead: startWallclock + offset) else {
                BitLog.w("Failed to create TimedMetadataEvent: mediaId=\(mediaId), offset=\(offset), playhead=\(startWallclock + offset)")
                continue
            }

            let mTimedMetadataEvent = TimedMetadataEvent(time: currentTime + offset, metadata: mEvent, rawTime: rawTime, normalizedTime: currentTimeAtStart)
            fireMetadataParsedEvent(event: mTimedMetadataEvent)
            timedMetadataEvents.append(mTimedMetadataEvent)

            offset += mEventInterval
        }

        // Generate E event
        let eEventDate = endDate.timeIntervalSince1970 + deviceOffsetFromPDT - adEventOffset
        guard let eEvent = YOTimedMetadata.create(withMediaId: mediaId, sequence: "1:1", type: "E", offset: (duration - adEventOffset).description, playhead: eEventDate) else {
            BitLog.w("Failed to create TimedMetadataEvent: mediaId=\(mediaId), offset=\(duration - adEventOffset), playhead=\(eEventDate)")
            return
        }

        let eTimedMetadataEvent = TimedMetadataEvent(time: currentTime + duration - adEventOffset, metadata: eEvent, rawTime: rawTime, normalizedTime: currentTimeAtStart)
        fireMetadataParsedEvent(event: eTimedMetadataEvent)
        timedMetadataEvents.append(eTimedMetadataEvent)

        timedMetadataEvents.forEach { BitLog.d("generated event: \($0.metadata.playhead), \($0.time)") }
    }

    func fireMetadataParsedEvent(event: TimedMetadataEvent) {
        let entries = [event.toYospaceId3MetadataEntry()]
        let metadata = Id3Metadata(entries: entries, startTime: event.time)
        let event = MetadataParsedEvent(metadata: metadata, type: .ID3)
        player?.listeners.forEach {
            if let bmPlayer = player?.bitmovinPlayer() {
                $0.onMetadataParsed?(event, player: bmPlayer)
            }
        }
    }

    func fireMetadataEvent(event: TimedMetadataEvent) {
        let entries = [event.toYospaceId3MetadataEntry()]
        let metadata = Id3Metadata(entries: entries, startTime: event.time)
        let event = MetadataEvent(metadata: metadata, type: .ID3)
        player?.listeners.forEach {
            if let bmPlayer = player?.bitmovinPlayer() {
                $0.onMetadata?(event, player: bmPlayer)
            }
        }
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
        
        let currentTime: Double = {
            if let playheadNormalizer = playheadNormalizer {
                return playheadNormalizer.currentNormalizedTime()
            } else {
                return player?.currentTimeWithAds() ?? event.currentTime
            }
        }()
        
        // Note - it's possible that there was a time jump between when the metadata was generated, and when it was activated here
        // If a jump does happen, the normalizer will be in ads mode and will move into normalizing for the remainder of the break
        // That should ensure that between date range metadata receipt -> ad break finished time will increase monotonically
        let nextEventTime = nextEvent.time
        
        // Send metadata event if playhead is within 1 second of metadata time
        if currentTime - nextEventTime >= -1 {
            timedMetadataEvents.removeFirst(1)
            let metadata = nextEvent.metadata
            BitLog.d("[onTimeChanged] - firing ID3: \(metadata.playhead)")
            
            // swiftlint:disable line_length
            BitLog.d("Sending metadata: currentDate=\(NSDate().timeIntervalSince1970), playerTime=\(currentTime), eventTime=\(nextEvent.time), metadataTime=\(metadata.playhead), id=\(metadata.mediaId), type=\(metadata.type), segment=\(metadata.segmentNumber), segmentCount=\(metadata.segmentCount), offset=\(metadata.offset)")
            // swiftlint:enable line_length

            player?.yospacesession?.timedMetadataWasCollected(metadata)
            fireMetadataEvent(event: nextEvent)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        reset()
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        reset()
    }

    func onError(_ event: Event) {
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
            segmentCount: Int(metadata.segmentCount),
            segmentNumber: Int(metadata.segmentNumber),
            offset: metadata.offset,
            timestamp: Date(timeIntervalSince1970: metadata.playhead)
        )
    }
}
