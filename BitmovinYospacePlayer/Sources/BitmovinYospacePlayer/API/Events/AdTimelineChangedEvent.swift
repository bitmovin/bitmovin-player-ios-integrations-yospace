import Foundation

public class AdTimelineChangedEvent: NSObject, BitmovinYospaceEvent {
    public let name: String
    public let timestamp: Double
    public let timeline: AdTimeline

    public init(name: String, timestamp: Double, timeline: AdTimeline) {
        self.name = name
        self.timeline = timeline
        self.timestamp = timestamp
    }
}
