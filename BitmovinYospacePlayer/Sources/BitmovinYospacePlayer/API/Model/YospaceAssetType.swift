import UIKit

@frozen
public enum YospaceAssetType: String {
    @available(*, deprecated, renamed: "dvrLive", message: "Use dvrLive for DVR live playback.")
    case linear
    case dvrLive
    case vod
}
