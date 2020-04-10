//
//  YSAdBreak+YospaceAdBreak.swift
//  Pods
//
//  Created by aneurinc on 4/2/20.
//

import Foundation
import Yospace

extension YSAdBreak {
    
    func toYospaceAdBreak(absoluteStart: Double, relativeStart: Double) -> YospaceAdBreak {
        let yospaceAdBreak = YospaceAdBreak(
            identifier: adBreakIdentifier(),
            absoluteStart: absoluteStart,
            absoluteEnd: absoluteStart + adBreakDuration(),
            duration: adBreakDuration(),
            relativeStart: relativeStart,
            scheduleTime: 0,
            replaceContentDuration: 0
        )
        
        // Add adverts to ad break
        var adAbsoluteStart = absoluteStart
        for case let advert as YSAdvert in adverts() {
            yospaceAdBreak.register(advert.toYospaceAd(absoluteStart: adAbsoluteStart, relativeStart: relativeStart))
            adAbsoluteStart += advert.advertDuration()
        }
        
        return yospaceAdBreak
    }
}
