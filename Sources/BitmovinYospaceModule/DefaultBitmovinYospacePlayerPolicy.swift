//
//  DefaultBitmovinYospacePlayerPolicy.swift
//  Pods
//
//  Created by Bitmovin on 11/19/18.
//

import Foundation

public class DefaultBitmovinYospacePlayerPolicy: BitmovinYospacePlayerPolicy {
    weak var player: BitmovinYospacePlayer?

    init(_ bitmovinYospacePlayer: BitmovinYospacePlayer) {
        player = bitmovinYospacePlayer
    }

    public func canMute() -> Bool {
        return true
    }

    public func canSeek() -> Bool {
        return true
    }

    public func canSeekTo(seekTarget: TimeInterval) -> TimeInterval {
        return seekTarget
    }

    public func canSkip() -> TimeInterval {
        return 0
    }

    public func canPause() -> Bool {
        return true
    }
}
