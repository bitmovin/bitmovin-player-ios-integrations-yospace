import UIKit

/// This enum is intentionally non-frozen so additional Yospace asset types can be added safely.
public enum YospaceAssetType: String {
    @available(*, deprecated, message: "Use `.dvrLive` for DVR live playback.")
    case linear
    case dvrLive
    case vod
}
