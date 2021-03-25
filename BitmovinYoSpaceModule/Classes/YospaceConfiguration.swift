//
//  YospaceConfiguration.swift
//  Pods
//
//  Created by Bitmovin on 11/16/18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

public class YospaceConfiguration {
    // MARK: - Yospace Configuration attributes
    let userAgent: String?
    let timeout: TimeInterval?
    let pollingInterval: Int?
    let debug: Bool

    // MARK: - initializer
    /**
     Initialize a new YospaceConfiguration object to change default behavior of the Yospace Ad Management SDK
     
     - Parameters:
     - isDebugEnabled: flag that enables debug logging of the Yospace Ad Management SDK
     - userAgent: Custom user agent that is sent with Yospace HTTP requests
     - timeout: HTTP timeout value in millisenconds to be used for Yospace HTTP requests
     
     */

    public init(userAgent: String? = nil, timeout: TimeInterval? = nil, pollingInterval: Int? = nil, debug: Bool = false) {
        self.userAgent = userAgent
        self.timeout = timeout
        self.pollingInterval = pollingInterval
        self.debug = debug
    }
}
