//
//  YospaceListener+PlayerListener.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Bitmovin on 11/13/18.
//

import BitmovinPlayerCore
import Foundation

@objc
public protocol YospaceListener: AnyObject, NSObjectProtocol {
    @objc optional
    func onAdTimelineChanged(event: AdTimelineChangedEvent, yospacePlayer: BitmovinYospacePlayer)
    @objc optional
    func onTrueXAdFree(event: TrueXAdFreeEvent, yospacePlayer: BitmovinYospacePlayer)
}
