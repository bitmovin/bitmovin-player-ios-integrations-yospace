//
//  YospacePlayer.swift
//  Pods
//
//  Created by Bitmovin on 11/18/18.
//

import Foundation
import Yospace
import BitmovinPlayer

class YospacePlayer: NSObject, YSVideoPlayer {

    required init(streamSource source: URL) {
        super.init()
    }

    // swiftlint:disable implicit_getter
    var currentTime: TimeInterval {
        get {
            return self.bitmovinYospacePlayer?.currentTimeWithAds() ?? 0
        }
    }

    var duration: TimeInterval {
        get {
            return self.bitmovinYospacePlayer?.durationWithAds() ?? 0
        }
    }
    // swiftlint:enable implicit_getter

    var rate: Float {
        get {
            return self.bitmovinYospacePlayer?.playbackSpeed ?? 0
        }
        set (rate) {
            self.bitmovinYospacePlayer?.playbackSpeed = rate
        }
    }

    weak var bitmovinYospacePlayer: BitmovinYospacePlayer?

    public init (bitmovinYospacePlayer: BitmovinYospacePlayer) {
        self.bitmovinYospacePlayer = bitmovinYospacePlayer
    }

}
