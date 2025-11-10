//
//  YospacePlayerPolicy.swift
//  Pods
//
//  Created by Bitmovin on 11/19/18.
//

import Foundation
import YOAdManagement

public class YospacePlayerPolicy: NSObject, YOPlaybackPolicyHandling {
    public func setSessionMode(_ sessionMode: YOSessionMode) {
        // TODO!
    }
    
    weak var playerPolicy: BitmovinYospacePlayerPolicy?

    public convenience init(bitmovinYospacePlayerPolicy: BitmovinYospacePlayerPolicy) {
        self.init()
        playerPolicy = bitmovinYospacePlayerPolicy
    }

    // MARK: YOPolicyHandling

    public func willSeek(to position: TimeInterval, timeline _: [Any], playhead _: TimeInterval) -> TimeInterval {
        return playerPolicy?.canSeekTo(seekTarget: position) ?? position
    }

    public func canChangeVolume(_: Bool, playhead _: TimeInterval, timeline _: [Any]) -> Bool {
        true
    }

    public func canResize(_: Bool, playhead _: TimeInterval, timeline _: [Any]) -> Bool {
        true
    }

    public func canResizeCreative(_: Bool, playhead _: TimeInterval, timeline _: [Any]) -> Bool {
        true
    }

    public func didSkip(from _: TimeInterval, to _: TimeInterval, timeline _: [Any]) {}

    public func didSeek(from _: TimeInterval, to _: TimeInterval, timeline _: [Any]) {}

    public func canStart(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canStop(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canPause(_: TimeInterval, timeline _: [Any]) -> Bool {
        return playerPolicy?.canPause() ?? true
    }

    public func canRewind(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canSkip(_: TimeInterval, timeline _: [Any], duration _: TimeInterval) -> TimeInterval {
        return playerPolicy?.canSkip() ?? -1
    }

    public func canSeek(_: TimeInterval, timeline _: [Any]) -> Bool {
        return playerPolicy?.canSeek() ?? true
    }

    public func canMute(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canGoFullScreen(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canExitFullScreen(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canExpandCreative(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canCollapseCreative(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }

    public func canClickThrough(_: URL, playhead _: TimeInterval, timeline _: [Any]) -> Bool {
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

    public func setPlaybackMode(_: YOPlaybackMode) {}
    
    // Additional methods that may be required by newer versions of YOPlaybackPolicyHandling
    public func canClickThroughOnAdBreak(_: TimeInterval, timeline _: [Any]) -> Bool {
        return true
    }
    
    public func shouldBlockPlaybackDuringAd() -> Bool {
        return false
    }
}
