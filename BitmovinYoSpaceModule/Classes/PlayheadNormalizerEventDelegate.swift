//
//  PlayheadNormalizerEventDelegate.swift
//  Pods
//
//  Created by cdg on 2/12/21.
//

import Foundation

protocol PlayheadNormalizerEventDelegate: AnyObject {
    func normalizingStarted()
    func normalizingFinished()
}
