//
//  AdBreak+Conversion.swift
//  Pods
//
//  Created by aneurinc on 4/2/20.
//

import Foundation
import Yospace

extension YSAdvert {
    
    func toYospaceAd(absoluteStart: Double, relativeStart: Double) -> YospaceAd {
        return YospaceAd(
            identifier: advertIdentifier(),
            absoluteStart: absoluteStart,
            absoluteEnd: advertEnd(),
            duration: advertDuration(),
            relativeStart: relativeStart,
            hasInteractiveUnit: hasLinearInteractiveUnit(),
            isLinear: !hasLinearInteractiveUnit(),
            clickThroughUrl: linearCreativeElement().linearClickthroughURL()
        )
    }
}
