//
//  YospaceListener+PlayerListener.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Bitmovin on 11/13/18.
//

import BitmovinPlayer
import Foundation

public protocol YospaceListener: AnyObject {
    func onTimelineChanged(event: AdTimelineChangedEvent)
    func onTrueXAdFree()
}
