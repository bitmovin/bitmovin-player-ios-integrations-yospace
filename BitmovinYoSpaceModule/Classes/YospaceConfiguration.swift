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
    let debug: Bool?
    let userAgent: String?
    let timeout: TimeInterval?
    let pollingInterval: Int?

    // MARK: - initializer
    /**
     Initialize a new YospaceConfiguration object to change default behavior of the Yospace Ad Management SDK
     
     - Parameters:
     - debug: flag that enables debug logging of the Yospace Ad Management SDK
     - userAgent: Custom user agent that is sent with Yospace HTTP requests
     - timeout: HTTP timeout value in millisenconds to be used for Yospace HTTP requests
     
     */
    public init (debug: Bool? = nil, userAgent: String? = nil, timeout: TimeInterval? = nil, pollingInterval: Int? = nil) {
        self.debug = debug
        self.userAgent = userAgent
        self.timeout = timeout
        self.pollingInterval = pollingInterval
    }
}
