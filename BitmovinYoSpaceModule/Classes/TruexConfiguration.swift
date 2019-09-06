//
//  TruexConfiguration.swift
//  BitmovinYospaceModule-iOS
//
//  Created by Cory Zachman on 2/14/19.
//

import Foundation
import UIKit

public class TruexConfiguration {
    let view: UIView
    let userId: String
    let vastConfigUrl: String
    // MARK: - initializer
    /**
     Initialize a new TruexConfiguration object.
     
     - Parameters:
     - view:
     - userId: 
     - vastConfigUrl:
     */
    public init(view: UIView, userId: String = "", vastConfigUrl: String = "") {
        self.view = view
        self.userId = userId
        self.vastConfigUrl = vastConfigUrl
    }
}
