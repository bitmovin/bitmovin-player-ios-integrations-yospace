//
//  YSAdBreak+YospaceAdBreak.swift
//  Pods
//
//  Created by aneurinc on 4/2/20.
//

import Foundation
import Yospace

extension YSAdBreak {
    
    func toYospaceAdBreak(relativeStart: Double) -> YospaceAdBreak {
        let yospaceAdBreak = YospaceAdBreak(
            identifier: adBreakIdentifier(),
            absoluteStart: adBreakStart(),
            absoluteEnd: adBreakEnd(),
            duration: adBreakDuration(),
            relativeStart: relativeStart,
            scheduleTime: 0,
            replaceContentDuration: 0
        )
        
        // Add adverts to ad break
        for case let advert as YSAdvert in adverts() {
            yospaceAdBreak.register(advert.toYospaceAd(relativeStart: relativeStart))
        }
        
        return yospaceAdBreak
    }
}
