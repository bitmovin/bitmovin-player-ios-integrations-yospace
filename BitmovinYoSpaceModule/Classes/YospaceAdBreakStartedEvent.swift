//
//  LiveAdBreakStartedEvent.swift
//  Pods
//
//  Created by Cory Zachman on 8/28/19.
//

import Foundation
import BitmovinPlayer

public class YospaceAdBreakStartedEvent: AdBreakStartedEvent {
    public var adBreak: AdBreak

    init(adBreak: AdBreak) {
        self.adBreak = adBreak
        super.init()
    }
}
