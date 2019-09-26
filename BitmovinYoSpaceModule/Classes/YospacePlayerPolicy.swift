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
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canStart")
        return true
    }

    public func canStop(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canStop")
        return true
    }

    public func canPause(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canPause")
        return self.playerPolicy?.canPause() ?? true
    }

    public func canRewind(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canRewind")
        return true
    }

    public func canSkip(_ playhead: TimeInterval, timeline: [Any], duration: TimeInterval) -> TimeInterval {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canSkip")
        return self.playerPolicy?.canSkip() ?? -1
    }

    public func canSeek(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canSeek")
        return self.playerPolicy?.canSeek() ?? true
    }

    public func willSeek(to position: TimeInterval, timeline: [Any]) -> TimeInterval {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] willSeek")
        return self.playerPolicy?.canSeekTo(seekTarget: position) ?? position
    }

    public func canMute(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canMute")
        return true
    }

    public func canGoFullScreen(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canGoFullScreen")
        return true
    }

    public func canExitFullScreen(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canExitFullScreen")
        return true
    }

    public func canExpandCreative(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canExpandCreative")
        return true
    }

    public func canCollapseCreative(_ playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canCollapseCreative")
        return true
    }

    public func canClickThrough(_ url: URL, playhead: TimeInterval, timeline: [Any]) -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] canClickThrough")
        return true
    }

    public func shouldPreloadNonLinearGraphicalElements() -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] shouldPreloadNonLinearGraphicalElements")
        return true
    }

    public func shouldPreloadIFrameResourceElements() -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] shouldPreloadIFrameResourceElements")
        return true
    }

    public func shouldPreloadInteractiveUnits() -> Bool {
        BitmovinLogger.d(message: "[YospacePlayerPolicy] shouldPreloadInteractiveUnits")
        return true
    }

    public func setPlaybackMode(_ playbackMode: YSEPlaybackMode) {
        BitmovinLogger.d(message: " [YospacePlayerPolicy] setPlaybackMode ")
    }
}
