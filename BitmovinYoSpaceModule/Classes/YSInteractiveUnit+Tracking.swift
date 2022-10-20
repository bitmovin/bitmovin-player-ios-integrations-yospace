//
//  YSInteractiveUnit+trackingEventDidOccur.swift
//  Pods
//
//  Created by aneurinc on 3/3/20.
//

import Foundation
import YOAdManagement

extension YOInteractiveCreative {
    func notifyAdStarted() {
        trackingEventDidOccur("creativeViewEvent")
    }

    func notifyAdStopped() {
        trackingEventDidOccur("generalTrackingEvent")
    }

    func notifyAdSkipped() {
        trackingEventDidOccur("skip")
    }

    func notifyAdImpression() {
        trackingEventDidOccur("impression")
    }

    func notifyAdVideoStarted() {
        trackingEventDidOccur("start")
    }
    
    func notifyAdVideoFirstQuartile() {
        trackingEventDidOccur("firstQuartile")
    }

    func notifyAdVideoMidpoint() {
        trackingEventDidOccur("midpoint")
    }

    func notifyAdVideoThirdQuartile() {
        trackingEventDidOccur("thirdQuartile")
    }

    func notifyAdVideoComplete() {
        trackingEventDidOccur("complete")
    }

    func notifyAdUserAcceptInvitation() {
        trackingEventDidOccur("acceptInvitation")
    }

    func notifyAdUserMinimize() {
        trackingEventDidOccur("playerCollapse")
    }
    
    func notifyAdUserClose() {
        trackingEventDidOccur("closeLinear")
    }

    func notifyAdPaused() {
        trackingEventDidOccur("pause")
    }

    func notifyAdPlaying() {
        trackingEventDidOccur("resume")
    }

    func notifyAdVolumeMuted() {
        trackingEventDidOccur("mute")
    }

    func notifyAdVolumeUnmuted() {
        trackingEventDidOccur("unmute")
    }
}
