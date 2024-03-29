import Foundation

public class TimeRange {
    /**
     * start of the time range
     */
    public var start: TimeInterval

    /**
     * end of the time range
     */
    public var end: TimeInterval

    public init(start: TimeInterval, end: TimeInterval) {
        self.start = start
        self.end = end
    }
}
