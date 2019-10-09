//
//  YospacePlayerPolicy.swift
//  Pods
//
//  Created by Bitmovin on 11/19/18.
//

import Foundation
import Yospace

class YospacePlayerPolicy: NSObject, YPPolicyHandling {
    weak var playerPolicy: BitmovinYospacePlayerPolicy?

    public convenience init(bitmovinYospacePlayerPolicy: BitmovinYospacePlayerPolicy) {
        self.init()
        self.playerPolicy = bitmovinYospacePlayerPolicy
    }

    // MARK: YPPolicyHandling
    public func canStart(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canStop(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canPause(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return self.playerPolicy?.canPause() ?? true
    }

    public func canRewind(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canSkip(_ playhead: TimeInterval, timeline: [Any], duration: TimeInterval) -> TimeInterval {
        return self.playerPolicy?.canSkip() ?? -1
    }

    public func canSeek(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return self.playerPolicy?.canSeek() ?? true
    }

    public func willSeek(to position: TimeInterval, timeline: [Any]) -> TimeInterval {
        return self.playerPolicy?.canSeekTo(seekTarget: position) ?? position
    }

    public func canMute(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canGoFullScreen(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canExitFullScreen(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canExpandCreative(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canCollapseCreative(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func canClickThrough(_ url: URL, playhead: TimeInterval, timeline: [Any]) -> Bool {
        return true
    }

    public func shouldPreloadNonLinearGraphicalElements() -> Bool {
        return true
    }

    public func shouldPreloadIFrameResourceElements() -> Bool {
        return true
    }

    public func shouldPreloadInteractiveUnits() -> Bool {
        return true
    }

    public func setPlaybackMode(_ playbackMode: YSEPlaybackMode) {

    }
}
