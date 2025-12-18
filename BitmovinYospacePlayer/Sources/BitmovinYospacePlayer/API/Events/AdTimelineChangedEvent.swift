import Foundation

public class AdTimelineChangedEvent: NSObject, BitmovinYospaceEvent {
    public let name: String = "onAdTimelineChanged"
    public let timestamp: Double = Date().timeIntervalSince1970
    public let timeline: AdTimeline

    public init(timeline: AdTimeline) {
        self.timeline = timeline
    }
}
