import UIKit

public enum YospaceAssetType: String {
    @available(*, deprecated, message: "Use dvrLive for DVR live playback.")
    case linear
    case dvrLive
    case vod
}
