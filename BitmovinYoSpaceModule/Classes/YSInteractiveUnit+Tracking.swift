//
//  YSInteractiveUnit+trackingEventDidOccur.swift
//  Pods
//
//  Created by aneurinc on 3/3/20.
//

import Foundation
import Yospace

extension YSInteractiveUnit {
    func notifyAdStarted() {
        trackingEventDidOccur(.creativeViewEvent)
    }

    func notifyAdStopped() {
        trackingEventDidOccur(.generalTrackingEvent)
    }

    func notifyAdSkipped() {
        trackingEventDidOccur(.skipEvent)
    }

    func notifyAdImpression() {
        trackingEventDidOccur(.impressionEvent)
    }

    func notifyAdVideoStarted() {
        trackingEventDidOccur(.startEvent)
    }

    func notifyAdVideoFirstQuartile() {
        trackingEventDidOccur(.firstQuartileEvent)
    }

    func notifyAdVideoMidpoint() {
        trackingEventDidOccur(.midpointEvent)
    }

    func notifyAdVideoThirdQuartile() {
        trackingEventDidOccur(.thirdQuartileEvent)
    }

    func notifyAdVideoComplete() {
        trackingEventDidOccur(.completeEvent)
    }

    func notifyAdUserAcceptInvitation() {
        trackingEventDidOccur(.acceptInvitationLinearEvent)
    }

    func notifyAdUserMinimize() {
        trackingEventDidOccur(.collapseEvent)
    }

    func notifyAdUserClose() {
        trackingEventDidOccur(.closeLinearEvent)
    }

    func notifyAdPaused() {
        trackingEventDidOccur(.pauseEvent)
    }

    func notifyAdPlaying() {
        trackingEventDidOccur(.resumeEvent)
    }

    func notifyAdVolumeMuted() {
        trackingEventDidOccur(.muteEvent)
    }

    func notifyAdVolumeUnmuted() {
        trackingEventDidOccur(.unmuteEvent)
    }
}
