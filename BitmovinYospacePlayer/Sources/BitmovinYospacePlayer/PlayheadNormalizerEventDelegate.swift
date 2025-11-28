//
//  PlayheadNormalizerEventDelegate.swift
//  Pods
//
//  Created by cdg on 2/12/21.
//

import Foundation

@objc public protocol PlayheadNormalizerEventDelegate: AnyObject {
    func normalizingStarted()
    func normalizingFinished()
}
