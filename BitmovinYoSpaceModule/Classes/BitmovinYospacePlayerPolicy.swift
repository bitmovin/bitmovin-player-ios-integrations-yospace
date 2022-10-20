//
//  BitmovinYospacePlayerPolicy.swift
//  Pods
//
//  Created by Bitmovin on 11/19/18.
//

import Foundation

public protocol BitmovinYospacePlayerPolicy: AnyObject {
    func canSeek() -> Bool
    func canSeekTo(seekTarget: TimeInterval) -> TimeInterval
    func canSkip() -> TimeInterval
    func canPause() -> Bool
}
