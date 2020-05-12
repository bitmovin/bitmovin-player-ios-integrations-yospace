//
//  YSEAdBreakPosition+AdBreakPosition.swift
//  Pods
//
//  Created by aneurinc on 5/12/20.
//

import Foundation
import Yospace

extension YSEAdBreakPosition {
    func toAdBreakPosition() -> AdBreakPosition {
        switch self {
        case .prerollPosition:
            return AdBreakPosition.preroll
        case .midrollPosition:
            return AdBreakPosition.midroll
        case .postrollPosition:
            return AdBreakPosition.postroll
        case .unknownPosition, _:
            return AdBreakPosition.unknown
        }
    }
}
