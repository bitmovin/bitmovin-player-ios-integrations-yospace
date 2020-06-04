//
//  YsAdvert+YospaceAd.swift
//  Pods
//
//  Created by aneurinc on 4/6/20.
//

import Foundation
import Yospace

extension YSAdvert {
    
    func toYospaceAd(absoluteStart: Double, relativeStart: Double) -> YospaceAd {
        return YospaceAd(
            identifier: advertIdentifier(),
            absoluteStart: absoluteStart,
            absoluteEnd: absoluteStart + advertDuration(),
            duration: advertDuration(),
            relativeStart: relativeStart,
            hasInteractiveUnit: hasLinearInteractiveUnit(),
            isLinear: !hasLinearInteractiveUnit(),
            clickThroughUrl: linearCreativeElement().linearClickthroughURL(),
            extensions:
            // advertExtensions() returns the "extensions" node
            // This function maps its child nodes to a list to match the Android API
            advertExtensions()?.children().compactMap { $0 as? YSXmlNode } ?? [YSXmlNode]()
        )
    }
}
