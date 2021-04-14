//
//  PlayheadNormalizer.swift
//  Pods
//
//  Created by cdg on 2/4/21.
//

import Foundation
import BitmovinPlayer

enum Mode: String {
    case unknown
    case metadataReceived
    case adsPlaying
    case mediaPlaying
}

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

    // Note - using two sets to allow for different sensitivities
    let maxAdsUnexpectedJumpForward = 1.5
    let maxAdsUnexpectedJumpBack = -0.5

    let maxDefaultUnexpectedJumpForward = 2.0
    let maxDefaultUnexpectedJumpBack = -0.5

    private weak var player: BitmovinYospacePlayer?
    private weak var eventDelegate: PlayheadNormalizerEventDelegate?

    // What mode we're in drives how any normalization is done
    private var mode: Mode = .unknown
    // For this pass, only normalize when we think we're in an ad-like mode
    private let normalizeByDefault = false

    private var processedFirstValue: Bool = false
    // Determines whether to normalize a passed time value
    private var active = false
    // The last raw playhead
    private var lastRawPlayhead: Double = 0.0
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

    init (player: BitmovinYospacePlayer, eventDelegate: PlayheadNormalizerEventDelegate) {
        super.init()
        self.player = player
        self.eventDelegate = eventDelegate

        self.player?.add(listener: self)
        self.log("Initialized")
    }

    // MARK: - private instance methods, general

    private func reset() {
        active = true

        setMode(.unknown)

        lastRawPlayhead = 0.0
        lastNormalizedPlayhead = 0.0
        lastGoodDelta = 0.0
        expectingJump = .none
        jumpEntries = []
        isSeeking = false
        resetInTimeChangedUpdateCount = -1
    }

    private func log(_ msg: String) {
        BitLog.d("\(msg)")
    }

    private func logV(_ msg: String) {
        if logVerbose {
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
        if jumpEntries.count > 20 {
            jumpEntries.remove(at: 0)
        }
    }
    /**
            Reset all playhead values - should only be called when an external signal tells us to reset:
     
                - on seeking / timeshifting
                - on either a time validation clamp (PDT, ad end)
     */
    private func resetPlayheadAndJumpStatus(time: Double) {
        log("Resetting playhead to: \(time) from \(lastRawPlayhead) | \(lastNormalizedPlayhead)")
        lastRawPlayhead = time
        lastNormalizedPlayhead = time

        setExpectingJump(.none)
    }

    private func setMode(_ newMode: Mode) {
        log("[setMode] updating from \(mode) to \(newMode)")
        mode = newMode
    }

    private func setExpectingJump(_ jump: Jump) {
        if (jump == expectingJump) {
            return
        }

        log("[setExpectingJump] updating from \(expectingJump) to \(jump)")
        expectingJump = jump

        if (expectingJump != .none) {
            eventDelegate?.normalizingStarted()
        } else {
            eventDelegate?.normalizingFinished()
        }

    }

    // MARK: - private instance methods, default / media playing modes

    /**
            By default, we normalize more aggressively, actively looking for a reciprocal jump. That's to limit the possibility of normalized drift, as there's currently no facility in the iOS BM player to surface the current fragment / PDT data from the manifest.
     
            Without a reciprocal jump, the only clamp will be an ad break, as we'll reset and use the curren playhead as the source of record at that point.
     */
    private func normalizeDefault(delta: Double, time: Double) -> Double {
        var normalizedTime: Double = 0.0

        if delta > maxDefaultUnexpectedJumpForward {
            if expectingJump == .forwards {
                // We jumped forward, and were expecting it
                log("✅ Received expected jump \(expectingJump) of \(delta); reset playhead to \(time)")
                normalizedTime = time
                setExpectingJump(.none)
                addJumpEntry(rawTime: time, delta: delta)
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped forward, and weren't expecting it
                setExpectingJump(.backwards)
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump forwards of \(delta); normalizing \(time) to \(normalizedTime)")
                addJumpEntry(rawTime: time, delta: delta)
            }
        } else if delta < maxDefaultUnexpectedJumpBack {
            if expectingJump == .backwards {
                // We jumped backwards, and were expecting it
                log("✅ Received expected jump \(expectingJump) of \(delta); reset playhead to \(time)")
                normalizedTime = time
                setExpectingJump(.none)
                addJumpEntry(rawTime: time, delta: delta)
                // TODO: ideally we have another check to clamp the bounds, to ensure the reverse jump was valid
            } else {
                // We jumped backward, and weren't expecting it
                setExpectingJump(.forwards)
                normalizedTime = incrementPrev()
                log("❌ Unexpected jump backwards of \(delta); normalizing \(time) to \(normalizedTime)")
                addJumpEntry(rawTime: time, delta: delta)
            }
        } else if expectingJump != .none {
            // We're expecting a reverse jump, but haven't received it yet
            // Continue to bump the last known good time incrementally
            normalizedTime = incrementPrev()
            log("Waiting for jump; normalizing incrementally to \(normalizedTime)")
        } else {
            // In all other cases, no normalization is necessary
            normalizedTime = time
            lastGoodDelta = delta
        }

        return normalizedTime
    }

    // MARK: - private instance methods, metadata / ads playing modes

    /**
            For ads, we normalize with the goal of ensuring that all date range metadata is processed, scheduled, and fired as close to accurately as possible. To facilitate, we center on:
            - using the receipt of date range timed metadata as an initial signal that ad break processing has begun
            - once ad break processing has begun, do standard normalization unless a jump of any kind is detected
            - if a single jump is detected, normalize for the remainder of the ad break
            - once ad break finished has fired, reset and use the current playhead as the source of record
     
            Note that there could be an edge case here, where date range timed metadata can be received but no ad break events are fired. For that case, we should have a fallback timer upon metadata receipt that will flip to an unknown mode after a given threshold.
     */
    private func normalizeAds(delta: Double, time: Double) -> Double {
        var normalizedTime: Double = 0.0

        // When in an ads mode, once we've received an unexpected jump, wait until the break has completed to reset
        if expectingJump != .none {
            // We're expecting a reverse jump, but haven't received it yet
            // Continue to bump the last known good time incrementally
            normalizedTime = incrementPrev()
            log("Waiting for jump; normalizing incrementally to \(normalizedTime)")
        } else if delta > maxAdsUnexpectedJumpForward {
            // We jumped forward, and weren't expecting it
            setExpectingJump(.backwards)
            normalizedTime = incrementPrev()
            log("❌ Unexpected jump forwards of \(delta); normalizing \(time) to \(normalizedTime)")
            addJumpEntry(rawTime: time, delta: delta)
        } else if delta < maxAdsUnexpectedJumpBack {
            // We jumped backward, and weren't expecting it
            setExpectingJump(.forwards)
            normalizedTime = incrementPrev()
            log("❌ Unexpected jump backwards of \(delta); normalizing \(time) to \(normalizedTime)")
            addJumpEntry(rawTime: time, delta: delta)
        } else {
            // In all other cases, no normalization is necessary
            normalizedTime = time
            lastGoodDelta = delta
        }

        return normalizedTime
    }

    // MARK: - public instance methods

    public func notifyDateRangeMetadataReceived() {
        // If we're already in an ads mode, don't reset again until the end of the ad break
        if (mode == .metadataReceived || mode == .adsPlaying) {
            return
        }

        log("[notifyDateRangeMetadataReceived] Resetting normalization and jump status - currently: \(expectingJump)")
        resetPlayheadAndJumpStatus(time: lastRawPlayhead)
        setMode(.metadataReceived)

        // TODO: we should likely start a timer here, and if no ad break started event has been received after a given threshold, switch to a status of unknown. Protects against an edge case were we have date range metadata, but an ad break does not start.
    }

    public func normalize(time: Double) -> Double {
//        log("normalizing \(time); previous \(prevPlayhead)")
        if !processedFirstValue {
            processedFirstValue = true
            lastRawPlayhead = time
            lastNormalizedPlayhead = time
            return lastNormalizedPlayhead
        }

        // If seeking, a time changed event should not be kicked up
        // If it is, return the last normalized value
        if isSeeking {
            log("Received time changed while seeking; returning last normalized value")
            return lastNormalizedPlayhead
        }

        // If the given time delta is over the respective thresholds, treat it as an unexpected jump
        let delta = time - lastRawPlayhead

        // If we've scheduled a reset in x number of time changed updates, reset here if appropriate
        if resetInTimeChangedUpdateCount > 0 {
            resetInTimeChangedUpdateCount -= 1

            if resetInTimeChangedUpdateCount == 0 {
                resetInTimeChangedUpdateCount = -1

                // If we're waiting for a jump, reset the time and jump status now
                // and return immediately
                //
                // This is necessary because there's no determinstic way, using the info surfaced by the iOS player,
                // to validate whether a jump is resetting things properly. Because of that, we're using ad break finished as a clamp.
                // On occasion, there has been a jump that occurs just after ad break finished, which invalidates the clamp.
                // This allows for waiting beyond the end of the ad break, to allow for any jumps that come in to be processed as a reset.
                if expectingJump != .none {
                    log("Hit scheduled reset")
                    resetPlayheadAndJumpStatus(time: time)

                    // If the delta is outside the range, add it to the jump list
                    if delta > maxDefaultUnexpectedJumpForward || delta < maxDefaultUnexpectedJumpBack {
                        addJumpEntry(rawTime: time, delta: delta)
                    }
                    return time
                } else {
                    log("No jump expected, skipping scheduled reset")
                }
            }
        }

        var normalizedTime: Double = 0.0
        if (mode == .metadataReceived || mode == .adsPlaying) {
            normalizedTime = normalizeAds(delta: delta, time: time)
        } else if normalizeByDefault {
            normalizedTime = normalizeDefault(delta: delta, time: time)
        } else {
            // If we're  not setup to normalize by default, log out a warning if we detect a jump
            if delta > maxDefaultUnexpectedJumpForward || delta < maxDefaultUnexpectedJumpBack {
                log("Warning - unexpected jump of \(delta) received while normalization is disabled")
            }
        }

        lastRawPlayhead = time
        lastNormalizedPlayhead = normalizedTime
        return normalizedTime
    }

    /**
            Given a raw, non-normalized time, look up the time change delta since that time
     */
    public func getDeltaSince(rawTime: Double) -> Double {
        var delta = 0.0
        if jumpEntries.isEmpty {
            return delta
        }

        // Start at the most recent, and work back
        var index = jumpEntries.count - 1
        while index >= 0 && jumpEntries[index].rawTime > rawTime {
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
        if deltaSince == 0.0 {
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
        // On source loaded, ensure all state is reset
        reset()

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
        setMode(.adsPlaying)
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
        setMode(.mediaPlaying)
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
