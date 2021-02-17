//
//  BitmovinYospaceConfiguration.swift
//  Pods
//
//  Created by cdg on 2/11/21.
//

import Foundation
import BitmovinPlayer

public class BitmovinYospaceConfiguration: NSObject {
    let playerConfiguration: PlayerConfiguration
    let yospaceConfiguration: YospaceConfiguration?
    let enablePlayheadNormalization: Bool
    
    public init(playerConfiguration: PlayerConfiguration, yospaceConfiguration: YospaceConfiguration? = nil, enablePlayheadNormalization: Bool = true) {
        self.playerConfiguration = playerConfiguration
        self.yospaceConfiguration = yospaceConfiguration
        self.enablePlayheadNormalization = enablePlayheadNormalization
    }
}
