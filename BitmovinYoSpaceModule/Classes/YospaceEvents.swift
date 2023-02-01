import Foundation
import BitmovinPlayer

public class YospaceWarningEvent: NSObject, Event {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval
    
    public init(errorCode: YospaceErrorCode, message: String) {
        self.name = String(format: "Yospace Warning %s", errorCode.rawValue.description)
        self.message = message
        self.timestamp = NSDate().timeIntervalSince1970
    }
}

public class YospaceErrorEvent: NSObject, Event {
    public var name: String
    public var message: String
    public var timestamp: TimeInterval
    
    public init(errorCode: YospaceErrorCode, message: String) {
        self.name = String(format: "Yospace Error %s", errorCode.rawValue.description)
        self.message = message
        self.timestamp = NSDate().timeIntervalSince1970
    }
}
