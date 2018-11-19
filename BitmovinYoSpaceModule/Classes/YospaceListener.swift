//
//  YospaceListener+PlayerListener.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Cory Zachman on 11/13/18.
//

import Foundation
import BitmovinPlayer

public protocol YospaceListener: class {
    func onYospaceError(event: ErrorEvent)
}
