import BitmovinYospaceModule
import Foundation

class BitmovinExamplePolicy: BitmovinYospacePlayerPolicy {
    // TODO: provide a better example
    func canSeek() -> Bool {
        return true
    }

    func canSeekTo(seekTarget: TimeInterval) -> TimeInterval {
        return seekTarget
    }

    func canSkip() -> TimeInterval {
        return 0
    }

    func canPause() -> Bool {
        NSLog("Example Policy Can Pause")
        return true
    }
}
