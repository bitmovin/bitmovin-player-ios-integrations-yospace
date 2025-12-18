import Foundation

public class TrueXAdFreeEvent: NSObject, BitmovinYospaceEvent {
    public var name = "onTrueXAdFree"
    public var timestamp: TimeInterval = Date().timeIntervalSince1970
}
