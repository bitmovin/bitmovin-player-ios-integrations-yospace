//
//  YospaceConfiguration.swift
//  Pods
//
//  Created by Bitmovin on 11/16/18.
//  Copyright (c) 2018 Bitmovin. All rights reserved.
//

import Foundation

@frozen
public enum YospaceDebugMode {
    /// Disables Yospace SDK trace output.
    case none
    /// Enables only the trace statements required by the Yospace validation procedure.
    case validation
    /// Enables all Yospace SDK trace output.
    case all
}

public class YospaceConfig {
    // MARK: - Yospace Configuration attributes

    let userAgent: String?
    let timeout: TimeInterval?
    let pollingInterval: Int?
    let yospaceDebugMode: YospaceDebugMode?

    // MARK: - initializer

    /**
     Initialize a new YospaceConfiguration object to change default behavior of the Yospace Ad Management SDK

     - Parameters:
     - userAgent: Custom user agent that is sent with Yospace HTTP requests
     - timeout: HTTP timeout value in milliseconds to be used for Yospace HTTP requests
     - pollingInterval: Resource timeout value used for Yospace polling requests
     - yospaceDebugMode: Trace output produced by the Yospace Ad Management SDK.
       When omitted, the SDK's existing global debug flags remain unchanged.

     */
    public init(
        userAgent: String? = nil,
        timeout: TimeInterval? = nil,
        pollingInterval: Int? = nil,
        yospaceDebugMode: YospaceDebugMode? = nil
    ) {
        self.userAgent = userAgent
        self.timeout = timeout
        self.pollingInterval = pollingInterval
        self.yospaceDebugMode = yospaceDebugMode
    }

    @available(*, deprecated, message: "Use init(userAgent:timeout:pollingInterval:yospaceDebugMode:) instead.")
    public convenience init(
        userAgent: String? = nil,
        timeout: TimeInterval? = nil,
        pollingInterval: Int? = nil,
        isDebugEnabled: Bool
    ) {
        self.init(
            userAgent: userAgent,
            timeout: timeout,
            pollingInterval: pollingInterval,
            yospaceDebugMode: isDebugEnabled ? .all : nil
        )
    }
}
