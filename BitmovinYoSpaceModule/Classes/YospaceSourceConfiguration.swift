//
//  YoSpaceSourceConfiguration.swift
//  BitmovinYoSpaceModule
//
//  Created by Cory Zachman on 10/26/18.
//

import UIKit
import BitmovinPlayer

public class YospaceSourceConfiguration {
    public let yoSpaceAssetType: YospaceAssetType
    public var timeout: TimeInterval = 5000
    public var debug: Bool = false
    public var userAgent: String = "BitmovinYospacePlayer"

    public init(yoSpaceAssetType: YospaceAssetType) {
        self.yoSpaceAssetType = yoSpaceAssetType
    }
}
