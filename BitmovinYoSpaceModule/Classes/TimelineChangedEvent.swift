//
//  TimelineChangedEvent.swift
//  Pods
//
//  Created by Cory Zachman on 12/20/18.
//

import Foundation

public class TimelineChangedEvent {
    public let name: String
    public let timestamp: Double
    public let timeline: Timeline

    public init(name: String, timestamp: Double, timeline: Timeline) {
        self.name = name
        self.timeline = timeline
        self.timestamp = timestamp
    }
}
