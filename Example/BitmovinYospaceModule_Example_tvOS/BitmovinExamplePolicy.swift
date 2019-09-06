//
//  BitmovinExamplePolicy.swift
//  BitmovinYospaceModule_Example_tvOS
//
//  Created by Cory Zachman on 11/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import BitmovinYospaceModule

class BitmovinExamplePolicy: BitmovinYospacePlayerPolicy {

    //TODO provide a better example
    func canSeek() -> Bool {
        return true
    }

    func canSeekTo(seekTarget: TimeInterval) -> TimeInterval {
        return seekTarget
    }

    func canSkip() -> TimeInterval {
        return 0
    }

    func canPause() -> Bool {
        NSLog("Example Policy Can Pause")
        return true
    }
}
