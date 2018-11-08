//
//  YospaceUtil.swift
//  BitmovinYoSpaceModule
//
//  Created by Cory Zachman on 11/6/18.
//

import UIKit
import Yospace

class YospaceUtil {
    
    static func trackingEventString(event: YSETrackingEvent) -> String{
        switch event {
        case .creativeViewEvent:
            return "creativeViewEvent"
        case .acceptInvitationEvent:
            return "acceptInvitationEvent"
        case .acceptInvitationLinearEvent:
            return "acceptInvitationLinearEvent"
        case .clickTrackingEvent:
            return "clickTrackingEvent"
        case .closeEvent:
            return "closeEvent"
        case .closeLinearEvent:
            return "closeLinearEvent"
        case .collapseEvent:
            return "collapseEvent"
        case .completeEvent:
            return "completeEvent"
        case .exitfullscreenEvent:
            return "exitfullscreenEvent"
        case .expandEvent:
            return "expandEvent"
        case .firstQuartileEvent:
            return "firstQuartileEvent"
        case .fullscreenEvent:
            return "fullscreenEvent"
        case .iconClickTrackingEvent:
            return "iconClickTrackingEvent"
        case .iconViewTrackingEvent:
            return "iconViewTrackingEvent"
        case .impressionEvent:
            return "impressionEvent"
        case .midpointEvent:
            return "midpointEvent"
        case .muteEvent:
            return "muteEvent"
        case .generalTrackingEvent:
            return "generalTrackingEvent"
        case .startEvent:
            return "startEvent"
        case .thirdQuartileEvent:
            return "thirdQuartileEvent"
        case .unmuteEvent:
            return "unmuteEvent"
        case .pauseEvent:
            return "pauseEvent"
        case .rewindEvent:
            return "rewindEvent"
        case .resumeEvent:
            return "resumeEvent"
        case .skipEvent:
            return "skipEvent"
        case .progressEvent:
            return "progressEvent"
        case .nonLinearClickTrackingEvent:
            return "nonLinearClickTrackingEvent"
        };
    }
}
