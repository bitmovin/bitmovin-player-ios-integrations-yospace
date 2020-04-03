//
//  YSAdBreak+Conversion.swift
//  Pods
//
//  Created by aneurinc on 4/2/20.
//

import Foundation
import Yospace

extension YSAdBreak {
    
    func toYospaceAdBreak() -> YospaceAdBreak {
        return YospaceAdBreak(
            identifier: adBreakIdentifier(),
            absoluteStart: adBreakStart(),
            absoluteEnd: adBreakEnd(),
            duration: adBreakDuration(),
            relativeStart: adBreakStart(),
            scheduleTime: 0,
            replaceContentDuration: 0
        )
    }
}
