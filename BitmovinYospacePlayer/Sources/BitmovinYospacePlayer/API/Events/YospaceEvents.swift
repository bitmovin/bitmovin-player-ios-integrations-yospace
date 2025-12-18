import BitmovinPlayerCore
import Foundation

public class YospaceWarningEvent: NSObject, BitmovinYospaceEvent {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval

    public init(errorCode: YospaceErrorCode, message: String) {
        name = "Yospace Warning \(errorCode.rawValue.description)"
        self.message = message
        timestamp = Date().timeIntervalSince1970
    }
}

public class YospaceErrorEvent: NSObject, BitmovinYospaceEvent {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval

    public init(errorCode: YospaceErrorCode, message: String) {
        name = "Yospace Error \(errorCode.rawValue.description)"
        self.message = message
        timestamp = Date().timeIntervalSince1970
    }
}
