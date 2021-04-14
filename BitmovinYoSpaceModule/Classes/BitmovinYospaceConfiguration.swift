//
//  BitmovinYospaceConfiguration.swift
//  Pods
//
//  Created by cdg on 2/11/21.
//

import Foundation
import BitmovinPlayer
import BitmovinAnalyticsCollector

public class BitmovinYospaceConfiguration: NSObject {
    let playerConfiguration: PlayerConfiguration
    let yospaceConfiguration: YospaceConfiguration?
    let analyticsConfiguration: BitmovinAnalyticsConfig?
    let enablePlayheadNormalization: Bool
    let debug: Bool

    public init(playerConfiguration: PlayerConfiguration, yospaceConfiguration: YospaceConfiguration? = nil, analyticsConfiguration: BitmovinAnalyticsConfig? = nil, enablePlayheadNormalization: Bool = true, debug: Bool = false) {
        self.playerConfiguration = playerConfiguration
        self.yospaceConfiguration = yospaceConfiguration
        self.analyticsConfiguration = analyticsConfiguration
        self.enablePlayheadNormalization = enablePlayheadNormalization
        self.debug = debug
    }
}
