//
//  PlayheadNormalizer.swift
//  Pods
//
//  Created by cdg on 2/4/21.
//

import Foundation
import BitmovinPlayer

enum Jump: String {
    case none
    case backwards
    case forwards
}

// TODO: public for test purposes
public class PlayheadNormalizer: NSObject {
    // MARK: - properties
    
    private weak var player: BitmovinYospacePlayer?
    
    private var processedFirstValue: Bool = false
    // Determines whether to normalize a passed time value
    private var active = false
    // The last raw playhead
    private var prevPlayhead: Double = 0.0
    // The last normalized playhead
    private var prevNormalizedPlayhead: Double = 0.0
    // The last delta that did not represent an unexpected jump or a timeshift
    private var lastGoodDelta: Double = 0.0
    // Default increment to use, if a good delta hasn't been calculated yet
    private var defaultIncrement: Double = 1.0
    // If we had an unexpected jump, expect the reverse jump
    private var expectingJump: Jump = .none
    // Ensure any seeks are not tracked as unexpected jumps
    // TODO:
    
    // MARK: - initializer
    
    public init (player: BitmovinYospacePlayer) {
        self.player = player
        
        // TODO - temp
        BitLog.isEnabled = true
    }
    
    // MARK: - private instance methods
    
    private func log(_ msg: String) {
        BitLog.d("[PlayheadNormalizer] \(msg)")
    }
    
    /**
           Given an unexpected jump, bump the previous known good playhead by an appropriate increment
     */
    private func incrementPrev() -> Double {
        let inc = (lastGoodDelta > 0.0) ? lastGoodDelta : defaultIncrement
        return prevNormalizedPlayhead + inc
    }
    
    // MARK: - public instance methods
    
    public func normalize(time: Double) -> Double {
        if (!processedFirstValue) {
            processedFirstValue = true
            prevPlayhead = time
            prevNormalizedPlayhead = time
            return prevNormalizedPlayhead
        }
        
        // If the given time delta is over the respective thresholds, treat it as an unexpected jump
        var normalizedTime: Double = 0.0
        let delta = time - prevPlayhead

        if (delta > 1.5) {
            if (expectingJump == .forwards) {
                // We jumped forward, and were expecting it
                log("Received expected jump \(expectingJump); reset playhead to \(time)")
                normalizedTime = time
                expectingJump = .none
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped forward, and weren't expecting it
                expectingJump = .backwards
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump forwards of \(delta); normalizing \(time) to \(normalizedTime)")
            }
        } else if (delta < -0.5) {
            if (expectingJump == .backwards) {
                // We jumped backwards, and were expecting it
                log("Received expected jump \(expectingJump); reset playhead to \(time)")
                normalizedTime = time
                expectingJump = .none
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped backward, and weren't expecting it
                expectingJump = .forwards
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump backwards of \(delta); normalizing \(time) to \(normalizedTime)")
            }
        } else if (expectingJump != .none) {
            // We're expecting a reverse jump, but haven't received it yet
            // Continue to bump the last known good time incrementally
            normalizedTime = incrementPrev()
            log("Waiting for jump; normalizing incrementally to \(normalizedTime)")
        } else {
            // In all other cases, no normalization is necessary
            normalizedTime = time
            lastGoodDelta = delta
        }
        
        prevPlayhead = time
        prevNormalizedPlayhead = normalizedTime
        return normalizedTime
    }
}

extension PlayheadNormalizer: PlayerListener {
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        // There's a potential optimization here, assuming the problem only happens inside an ad break, after it's already started
        // As long as we're normalizing inside an ad break, we should be able to guarantee that an ad break end will be hit (baseline scenario)
        
        //active = true
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        //active = false
    }
    
    public func onSeek(_ event: SeekEvent) {
        // VOD - Seek started
    }
    public func onSeeked(_ event: SeekedEvent) {
        // VOD - Seek ended
    }
    
    public func onTimeShift(_ event: TimeShiftEvent) {
        // Live - Seek started
    }
    
    public func onTimeShifted(_ event: TimeShiftedEvent) {
        // Live - Seek ended
    }
}
