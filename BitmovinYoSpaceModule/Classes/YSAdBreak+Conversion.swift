//
//  YSAdBreak+Conversion.swift
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
            absoluteEnd: adBreakEnd(),
            duration: adBreakDuration(),
            relativeStart: relativeStart,
            scheduleTime: 0,
            replaceContentDuration: 0
        )
        
        // Add adverts to ad break
        var advertAbsoluteStart = absoluteStart
        for case let advert as YSAdvert in adverts() {
            yospaceAdBreak.register(advert.toYospaceAd(absoluteStart: advertAbsoluteStart, relativeStart: relativeStart))
            advertAbsoluteStart += advert.advertDuration()
        }
        
        return yospaceAdBreak
    }
}
