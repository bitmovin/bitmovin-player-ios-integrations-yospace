import BitmovinPlayerCore
import Foundation

public class YospaceWarningEvent: NSObject, Event {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval

    public init(errorCode: YospaceErrorCode, message: String) {
        name = String(format: "Yospace Warning %s", errorCode.rawValue.description)
        self.message = message
        timestamp = NSDate().timeIntervalSince1970
    }
}

public class YospaceErrorEvent: NSObject, Event {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval

    public init(errorCode: YospaceErrorCode, message: String) {
        name = String(format: "Yospace Error %s", errorCode.rawValue.description)
        self.message = message
        timestamp = NSDate().timeIntervalSince1970
    }
}
