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
//        trackingEventDidOccur(NSNotification.Name.YOTrackingEvent.rawValue)
        trackingEventDidOccur("creativeViewEvent")
    }

    func notifyAdStopped() {
        trackingEventDidOccur("generalTrackingEvent")
    }

    func notifyAdSkipped() {
        trackingEventDidOccur("skip")
    }

    func notifyAdImpression() {
//        trackingEventDidOccur(.impressionEvent)
    }

    func notifyAdVideoStarted() {
        trackingEventDidOccur("start")
    }

    func notifyAdVideoFirstQuartile() {
        trackingEventDidOccur("firstQuartile")
    }

    func notifyAdVideoMidpoint() {
//        trackingEventDidOccur(.midpointEvent)
    }

    func notifyAdVideoThirdQuartile() {
//        trackingEventDidOccur(.thirdQuartileEvent)
    }

    func notifyAdVideoComplete() {
//        trackingEventDidOccur(.completeEvent)
    }

    func notifyAdUserAcceptInvitation() {
//        trackingEventDidOccur(.acceptInvitationLinearEvent)
    }

    func notifyAdUserMinimize() {
//        trackingEventDidOccur(.collapseEvent)
    }

    func notifyAdUserClose() {
//        trackingEventDidOccur(.closeLinearEvent)
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
