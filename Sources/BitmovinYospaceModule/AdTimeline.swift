import BitmovinPlayerCore
import Foundation
import YOAdManagement

public class AdTimeline: CustomDebugStringConvertible {
    public private(set) var adBreaks: [YospaceAdBreak] = []

    public init(adBreaks: [YOAdBreak]) {
        var relativeOffset = 0.0
        adBreaks.sorted { $0.start < $1.start }
            .forEach {
                let adBreak = $0.toYospaceAdBreak(absoluteStart: $0.start, relativeStart: $0.start - relativeOffset)
                self.adBreaks.append(adBreak)
                relativeOffset += adBreak.duration
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
        let passedAdBreakDurations = adBreaks.filter { $0.relativeStart < time }.reduce(0) { $0 + $1.duration }
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
        let passedAdBreakDurations = adBreaks.filter { $0.absoluteEnd < time }.reduce(0) { $0 + $1.duration }

        // Check if we are in an ad break, the relative time if you are in an ad break is equal to the ad breaks start time
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return time - passedAdBreakDurations
        }

        return currentAdBreak.absoluteStart - passedAdBreakDurations
    }

    func currentAdBreak(time: TimeInterval) -> YospaceAdBreak? {
        return adBreaks.filter { $0.absoluteStart < time }.filter { $0.absoluteEnd > time }.first
    }

    func currentAd(time: TimeInterval) -> YospaceAd? {
        guard let currentAdBreak = currentAdBreak(time: time) else {
            return nil
        }

        return currentAdBreak.ads
            .compactMap { $0 as? YospaceAd }
            .filter { $0.absoluteStart < time }
            .filter { $0.absoluteEnd > time }
            .first
    }
}
