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

struct JumpEntry {
    let rawTime: Double
    let delta: Double
}

// TODO: public for test purposes
public class PlayheadNormalizer: NSObject {
    // MARK: - properties
    
    // TODO: make these relative to the Yospace timeout length
    let MAX_UNEXPECTED_JUMP_FORWARD = 2.0
    let MAX_UNEXPECTED_JUMP_BACK = -0.5
    
    private weak var player: BitmovinYospacePlayer?
    
    private var processedFirstValue: Bool = false
    // Determines whether to normalize a passed time value
    private var active = false
    // The last raw playhead
    private var lastPlayhead: Double = 0.0
    // The last normalized playhead
    private var lastNormalizedPlayhead: Double = 0.0
    // The last delta that did not represent an unexpected jump or a timeshift
    private var lastGoodDelta: Double = 0.0
    // Default increment to use, if a good delta hasn't been calculated yet
    private var defaultIncrement: Double = 1.0
    // If we had an unexpected jump, expect the reverse jump
    private var expectingJump: Jump = .none
    // Track the last n number of jumps
    private var jumpEntries: [JumpEntry] = []
    // Ensure any seeks are not tracked as unexpected jumps
    private var isSeeking: Bool = false
    // Allows a reset to happen a set number of time changed updates after an event
    // More info on why this is needed in the ad break events
    private var resetInTimeChangedUpdateCount: Int = -1
    
    private var logVerbose = false
    
    // MARK: - initializer
    
    public init (player: BitmovinYospacePlayer) {
        super.init()
        self.player = player
        self.player?.add(listener: self)
        self.log("Initialized")
    }
    
    // MARK: - private instance methods
    
    private func log(_ msg: String) {
//        BitLog.d("[PlayheadNormalizer] \(msg)")
        
        // For targeted test logging always print for now
        // TODO: Switch to the above before merging
        print("cdg - [PlayheadNormalizer] \(msg)")
    }
    
    private func logV(_ msg: String) {
        if (logVerbose) {
            log(msg)
        }
    }
    /**
           Given an unexpected jump, bump the previous known good playhead by an appropriate increment
     */
    private func incrementPrev() -> Double {
        let inc = (lastGoodDelta > 0.0) ? lastGoodDelta : defaultIncrement
        return lastNormalizedPlayhead + inc
    }
    
    private func addJumpEntry(rawTime: Double, delta: Double) {
        log("Adding jump entry: \(rawTime) | \(delta)")
        jumpEntries.append(JumpEntry(rawTime: rawTime, delta: delta))
        
        // We only need to preserve entries for calculations to be adjusted, which shouldn't go beyond an ad break
        // Pruning at 20 to be safe
        if (jumpEntries.count > 20) {
            jumpEntries.remove(at: 0)
        }
    }
    /**
            Reset all playhead values - should only be called when an external signal tells us to reset:
     
                - on seeking / timeshifting
                - on either a time validation clamp (PDT, ad end)
     */
    private func resetPlayheadAndJumpStatus(time: Double) {
        log("Resetting playhead to: \(time) from \(lastPlayhead) | \(lastNormalizedPlayhead)")
        lastPlayhead = time
        lastNormalizedPlayhead = time
        expectingJump = .none
    }
    
    // MARK: - public instance methods
    
    public func normalize(time: Double) -> Double {
//        log("normalizing \(time); previous \(prevPlayhead)")
        if (!processedFirstValue) {
            processedFirstValue = true
            lastPlayhead = time
            lastNormalizedPlayhead = time
            return lastNormalizedPlayhead
        }
        
        // If seeking, a time changed event should not be kicked up
        // If it is, return the last normalized value
        if (isSeeking) {
            log("Received time changed while seeking; returning last normalized value")
            return lastNormalizedPlayhead
        }
        
        // If the given time delta is over the respective thresholds, treat it as an unexpected jump
        var normalizedTime: Double = 0.0
        let delta = time - lastPlayhead
        
        // If we've scheduled a reset in x number of time changed updates, reset here if appropriate
        if (resetInTimeChangedUpdateCount > 0) {
            resetInTimeChangedUpdateCount -= 1
            
            if (resetInTimeChangedUpdateCount == 0) {
                resetInTimeChangedUpdateCount = -1
                
                // If we're waiting for a jump, reset the time and jump status now
                // and return immediately
                //
                // This is necessary because there's no determinstic way, using the info surfaced by the iOS player,
                // to validate whether a jump is resetting things properly. Because of that, we're using ad break finished as a clamp.
                // On occasion, there has been a jump that occurs just after ad break finished, which invalidates the clamp.
                // This allows for waiting beyond the end of the ad break, to allow for any jumps that come in to be processed as a reset.
                if (expectingJump != .none) {
                    log("Hit scheduled reset")
                    resetPlayheadAndJumpStatus(time: time)
                    
                    // If the delta is outside the range, add it to the jump list
                    if (delta > MAX_UNEXPECTED_JUMP_FORWARD || delta < MAX_UNEXPECTED_JUMP_BACK) {
                        addJumpEntry(rawTime: time, delta: delta)
                    }
                    return time
                }
            }
        }
        
        if (delta > MAX_UNEXPECTED_JUMP_FORWARD) {
            if (expectingJump == .forwards) {
                // We jumped forward, and were expecting it
                log("✅ Received expected jump \(expectingJump) of \(delta); reset playhead to \(time)")
                normalizedTime = time
                expectingJump = .none
                addJumpEntry(rawTime: time, delta: delta)
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped forward, and weren't expecting it
                expectingJump = .backwards
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump forwards of \(delta); normalizing \(time) to \(normalizedTime)")
                addJumpEntry(rawTime: time, delta: delta)
            }
        } else if (delta < MAX_UNEXPECTED_JUMP_BACK) {
            if (expectingJump == .backwards) {
                // We jumped backwards, and were expecting it
                log("✅ Received expected jump \(expectingJump) of \(delta); reset playhead to \(time)")
                normalizedTime = time
                expectingJump = .none
                addJumpEntry(rawTime: time, delta: delta)
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped backward, and weren't expecting it
                expectingJump = .forwards
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump backwards of \(delta); normalizing \(time) to \(normalizedTime)")
                addJumpEntry(rawTime: time, delta: delta)
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
        
        lastPlayhead = time
        lastNormalizedPlayhead = normalizedTime
        return normalizedTime
    }
    
    /**
            Given a raw, non-normalized time, look up the time change delta since that time
     */
    public func getDeltaSince(rawTime: Double) -> Double {
        var delta = 0.0
        if (jumpEntries.isEmpty) {
            return delta
        }
        
        // Start at the most recent, and work back
        var index = jumpEntries.count - 1
        while (index >= 0 && jumpEntries[index].rawTime > rawTime) {
            delta += jumpEntries[index].delta
            index -= 1
        }
        
        logV("[getDeltaSince] delta: \(delta)")
        return delta
    }
    
    /**
            Given a raw base time, and the normalization that was done initially, this method will check for additional time jumps that apply and update the normalized time w/ the delta
     
            Given the following sequence:
            - have an initial playhead of 1000
            - have a jump back of -5 - raw: 995, normalized: 1001 (delta: 6)
            - generate metadata against the normalized time: 1001
            - have a jump forward of 7 - raw: 1002, normalized: 1002  (delta: 7)
            - normalizeToCurrent on generated metadata (995, 1001) -> (7)ds -> (1001 - 995)i -> (-1)rd -> 1001 - -1 -> 1002
     */
    public func normalizeToCurrent(rawTime: Double, normalized: Double) -> Double {
        let deltaSince = getDeltaSince(rawTime: rawTime)
        if (deltaSince == 0.0) {
            return normalized
        }
        
        let initialDelta = normalized - rawTime
        let remainingDelta = deltaSince - initialDelta
        logV("[normalizeToCurrent] initial: \(normalized), \(rawTime), \(initialDelta) | remaining: \(remainingDelta) | n: \(normalized - remainingDelta)")
        return normalized - remainingDelta
    }
    
    public func currentNormalizedTime() -> Double {
        logV("[currentNormalizedTime] \(lastNormalizedPlayhead)")
        return lastNormalizedPlayhead
    }
}

extension PlayheadNormalizer: PlayerListener {
    public func onReady(_ event: ReadyEvent) {
        guard let player = player else {
            return
        }
        
        // Seed the first values, to ensure there's an initial normalized value for the date emitter
        // to query if there's a preroll
        let initialPlayhead = normalize(time: player.currentTimeWithAds())
        log("initial playhead: \(initialPlayhead)")
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        // There's a potential optimization here, assuming the problem only happens inside an ad break, after it's already started
        // As long as we're normalizing inside an ad break, we should be able to guarantee that an ad break end will be hit (baseline scenario)
        
        //active = true
        log("Ad break started")
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        //active = false
        
        // Note - given we the player doesn't raise enough events for us to use PDT as a clamp,
        // using this instead
        // This may have the side effect of causing ad events / beacons to be slightly offset,
        // if future date range metadata was received during an ad break which had a time jump
        // That should never happen, given that the DateEmitter is using onMetadata, which should only fire
        // when metadata is encountered for an actively playing fragment, but noting the possibility
        
        // On occasion, there has been a reciprocal time jump received just after an ad break end
        // Because of that, and because we still want to clamp to prevent normalized drift,
        // scheduling a reset 2 timed changed events (e.g., 2 secs) in the future
        resetInTimeChangedUpdateCount = 2
        log("Ad break finished - scheduled a reset in \(resetInTimeChangedUpdateCount)")
    }
    
    public func onSeek(_ event: SeekEvent) {
        // VOD - Seek started
        log("VOD Seek started - \(event.seekTarget)")
        isSeeking = true
    }
    public func onSeeked(_ event: SeekedEvent) {
        guard let player = player else {
            return
        }
        
        // VOD - Seek ended
        let updatedTime = player.currentTimeWithAds()
        log("VOD Seek finished - resetting to \(updatedTime)")
        resetPlayheadAndJumpStatus(time: updatedTime)
        isSeeking = false
    }
    
    public func onTimeShift(_ event: TimeShiftEvent) {
        // Live - Seek started
        log("Live Seek started - \(event.timeShift)")
        isSeeking = true
    }
    
    public func onTimeShifted(_ event: TimeShiftedEvent) {
        // Live - Seek ended
        guard let player = player else {
            return
        }
        
        // VOD - Seek ended
        let updatedTime = player.currentTimeWithAds()
        log("Live Seek finished - resetting to \(updatedTime)")
        resetPlayheadAndJumpStatus(time: updatedTime)
        isSeeking = false
    }
}
