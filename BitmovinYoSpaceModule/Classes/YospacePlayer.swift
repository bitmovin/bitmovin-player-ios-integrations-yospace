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

    var currentTime: TimeInterval {
        get {
            return self.bitmovinYospacePlayer?.currentTime ?? 0
        }
    }

    var duration: TimeInterval {
        get {
            return self.bitmovinYospacePlayer?.duration ?? 0
        }
    }

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
