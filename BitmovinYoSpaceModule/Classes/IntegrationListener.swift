//
//  IntegrationListener.swift
//  Pods
//
//  Created by cdg on 2/12/21.
//

import Foundation

public protocol IntegrationListener: class {
    func onPlayheadNormalizingStarted()
    func onPlayheadNormalizingFinished()
}
