//
//  BitmovinTruexRendererDelegate.swift
//  Pods
//
//  Created by aneurinc on 3/3/20.
//

import Foundation

@objc public protocol TruexAdRendererEventDelegate: AnyObject {
    func skipAdBreak()
    func skipTruexAd()
    func sessionAdFree()
}
