import UIKit
import BitmovinPlayer
import Yospace

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

public class BitmovinYospacePlayer: BitmovinPlayer {
    // MARK: - Bitmovin Yospace Player attributes
    var sessionManager: YSSessionManager?
    var yospaceStream: YSStream?
    var sessionStatus: SessionStatus = .notInitialised
    var adPlaying = false
    var yospaceSourceConfiguration: YospaceSourceConfiguration?
    var yospaceConfiguration: YospaceConfiguration?
    var sourceConfiguration: SourceConfiguration?
    var listeners: [PlayerListener] = []
    var yospacePlayerPolicy: YospacePlayerPolicy?
    var yospacePlayer: YospacePlayer?
    var yospaceListeners: [YospaceListener] = []
    var adBreaks: [YSAdBreak] = []

    // pass along the BitmovinYospacePlayerPolicy to the internal yospacePlayerPolicy which will be called by by our sessionManager
    public var playerPolicy: BitmovinYospacePlayerPolicy? {
        set (playerPolicy) {
            self.yospacePlayerPolicy?.playerPolicy = playerPolicy
        }
        get {
            return self.yospacePlayerPolicy?.playerPolicy
        }
    }

    public override var duration: TimeInterval {
        return super.duration - self.adBreaks.reduce(0) {$0 + $1.adBreakDuration()}
    }

    public override var currentTime: TimeInterval {

        //Check if we are in an ad break
        let currentAdBreaks = adBreaks.filter {$0.adBreakStart() < super.currentTime}.filter {$0.adBreakEnd() > super.currentTime}
        for currentAdBreak: YSAdBreak in currentAdBreaks {
            return currentAdBreak.adBreakStart()
        }

        let passedAdBreakDurations = adBreaks.filter {$0.adBreakEnd() < super.currentTime}.reduce(0) { $0 + $1.adBreakDuration() }

        return super.currentTime - passedAdBreakDurations
    }

    // MARK: - initializer
    /**
     Initializea new Bitmovin Yospace player for SSAI with Yospace
     
     **!! The BitmovinYospacePlayer will only be able to play Yospace streams. It will error out on all other streams. Please add a YospaceListener to be notified of these errors !!**
     
     - Parameters:
     - configuration: Traditional PlayerConfiguration used by Bitmovin
     - yospaceConfiguration: YospaceConfiguration object that changes the behavior of the internal Yospace AD Management SDK
     */
    public init(configuration: PlayerConfiguration, yospaceConfiguration: YospaceConfiguration?) {
        super.init(configuration: configuration)
        sessionStatus = .notInitialised
        super.add(listener: self)
    }

    public override func destroy() {
        resetSessionManager()
        yospaceListeners.removeAll()
        listeners.removeAll()
        super.destroy()
    }

    // MARK: loading a yospace source

    /**
     Loads a new yospace source into the player
     
     **!! The BitmovinYospacePlayer will only be able to play Yospace streams. It will error out on all other streams. Please add a YospaceListener to be notified of these errors !!**
     
     - Parameters:
     - sourceConfiguration: SourceConfiguration of your Yospace HLSSource
     - yospaceConfiguration: YospaceConfiguration to be used during this session playback. You must identify the source as .linear .vod or .startOver
     */
    public func load(sourceConfiguration: SourceConfiguration, yospaceSourceConfiguration: YospaceSourceConfiguration) {
        resetSessionManager()
        self.yospaceSourceConfiguration = yospaceSourceConfiguration
        self.sourceConfiguration = sourceConfiguration
        let yospaceProperties = YSSessionProperties()

        if let timeout = yospaceConfiguration?.timeout {
            yospaceProperties.timeout = timeout
        }

        if let timeout = yospaceConfiguration?.timeout {
            yospaceProperties.timeout = timeout
        }

        if let userAgent = yospaceConfiguration?.userAgent {
            yospaceProperties.analyticsUserAgent = userAgent
            yospaceProperties.analyticsUserAgent = userAgent
        }

        if yospaceConfiguration?.debug != nil {
            let combined = YSEDebugFlags(rawValue: YSEDebugFlags.DEBUG_ID3TAG.rawValue | YSEDebugFlags.DEBUG_REPORTS.rawValue)
            YSSessionProperties.add(_:combined!)
        }

        guard let url: URL = self.sourceConfiguration?.firstSourceItem?.hlsSource?.url else {
            handleError(code: YospaceErrorCode.invalidSource.rawValue, message: "Invalid source provided. Yospace URL must be HLS")
            return
        }

        switch yospaceSourceConfiguration.yospaceAssetType {
        case .linear:
            loadLive(url: url, yospaceProperties: yospaceProperties)
        case .nonLinearStartOver:
            loadNonLinearStartOver(url: url, yospaceProperties: yospaceProperties)
        case .vod:
            loadVOD(url: url, yospaceProperties: yospaceProperties)
        }
    }

    func resetSessionManager() {
        self.sessionManager?.shutdown()
        self.sessionManager = nil
        self.yospaceStream = nil
        self.adBreaks = []
        sessionStatus = .notInitialised
        adPlaying = false
    }

    func loadVOD(url: URL, yospaceProperties: YSSessionProperties) {
        YSSessionManager.create(forVoD: url, properties: yospaceProperties, delegate: self)
    }

    func loadLive(url: URL, yospaceProperties: YSSessionProperties) {
        YSSessionManager.create(forLive: url, properties: yospaceProperties, delegate: self)
    }

    func loadNonLinearStartOver(url: URL, yospaceProperties: YSSessionProperties) {
        YSSessionManager.create(forNonLinearStartOver: url, properties: yospaceProperties, delegate: self)
    }

    public func clickThroughPressed() {
        sessionManager?.linearClickThroughDidOccur()
    }

    // MARK: - time normalization

    // MARK: - playback methods
    public override func pause() {
        if let manager = self.sessionManager {
            if !manager.canPause() {
                NSLog("pause() rejected")
                return
            }
        }
        super.pause()
    }

    public override func seek(time: TimeInterval) {
        if let manager = self.sessionManager {
            super.seek(time: manager.willSeek(to: time))
        } else {
            super.seek(time: time)
        }
    }

    // MARK: - event handling
    public override func add(listener: PlayerListener) {
        listeners.append(listener)
    }

    public override func remove(listener: PlayerListener) {
        listeners = listeners.filter { $0 !== listener }
    }

    public func add(yospaceListener: YospaceListener) {
        yospaceListeners.append(yospaceListener)
    }

    public func remove(yospaceListener: YospaceListener) {
        yospaceListeners = yospaceListeners.filter { $0 !== yospaceListener }
    }

    func handleError(code: UInt, message: String) {
        for listener: YospaceListener in yospaceListeners {
            listener.onYospaceError(event: ErrorEvent(code: code, message: message))
        }
    }

    #if os(iOS)
    public override func skipAd() {
        if sessionStatus != .notInitialised {
            guard sessionManager != nil else {
                return
            }

            let adBreak: YSAdBreak? = currentAdBreak()
            if let currentBreak = adBreak {

                super.seek(time: currentBreak.adBreakEnd())
            }
        } else {
            super.skipAd()
        }
    }

    public override var isAd: Bool {
        if sessionStatus != .notInitialised {
            return adPlaying
        } else {
            return super.isAd
        }
    }
    #endif

    func currentAdBreak() -> YSAdBreak? {
        let currentAdBreaks = adBreaks.filter {$0.adBreakStart() < super.currentTime}.filter {$0.adBreakEnd() > super.currentTime}
        for currentAdBreak: YSAdBreak in currentAdBreaks {
            return currentAdBreak
        }

        return nil
    }

    public func currentTimeWithAds() -> TimeInterval {
        return super.currentTime
    }

    public func durationWithAds() -> TimeInterval {
        return super.duration
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer: YSAnalyticObserver {
    public func advertBreakDidStart(_ adBreak: YSAdBreak) {
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(AdBreakStartedEvent())
        }
    }

    public func advertBreakDidEnd(_ adBreak: YSAdBreak) {
        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(AdBreakFinishedEvent())
        }
    }

    public func advertDidStart(_ advert: YSAdvert) -> [Any]? {
        adPlaying = true
        var clickThroughUrl: URL = URL(fileURLWithPath: "", relativeTo: nil)

        if advert.linearCreativeElement().linearClickthroughURL() != nil {
            clickThroughUrl = advert.linearCreativeElement().linearClickthroughURL()!
        }

        //swiftlint:disable line_length
        let adStartedEvent: AdStartedEvent = AdStartedEvent(clickThroughUrl: clickThroughUrl, clientType: .IMA, indexInQueue: 0, duration: advert.advertDuration(), timeOffset: advert.advertStart(), skipOffset: 1, position: "0")
        //swiftlint:enable line_length

        for listener: PlayerListener in listeners {
            listener.onAdStarted?(adStartedEvent)
        }
        return []
    }

    public func advertDidEnd(_ advert: YSAdvert) {
        adPlaying = false
        for listener: PlayerListener in listeners {
            listener.onAdFinished?(AdFinishedEvent())
        }
    }

    public func trackingEventDidOccur(_ event: YSETrackingEvent, for advert: YSAdvert) {
        NSLog("Tracking Event Did Occur %@", YospaceUtil.trackingEventString(event: event))
    }

    public func linearClickThroughDidOccur(_ linearCreative: YSLinearCreative) {
        for listener: PlayerListener in listeners {
            listener.onAdClicked?(AdClickedEvent(clickThroughUr: linearCreative.linearClickthroughURL()))
        }
    }

    public func nonlinearClickThroughDidOccur(_ nonlinearCreative: YSNonLinearCreative) {

    }

    public func contentDidEnd(_ playheadPosition: TimeInterval) {
        NSLog("Content did end")
    }

    public func contentDidPause(_ playheadPosition: TimeInterval) {
        NSLog("Content did pause")
    }

    public func contentDidStart(_ playheadPosition: TimeInterval) {
        NSLog("Content did start")
    }

    public func contentDidResume(_ playheadPosition: TimeInterval) {
        NSLog("Content did resume")
    }

    public func timelineUpdateReceived(_ vmap: String) {
        NSLog("Timeline Updated")
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer: YSSessionManagerObserver {
    public func sessionDidInitialise(_ sessionManager: YSSessionManager, with stream: YSStream) {

        self.sessionManager = sessionManager
        self.yospaceStream = stream
        if let timeline = self.yospaceStream?.timeline() as? [YSAdBreak] {
            self.adBreaks = timeline
        }

        self.sessionManager?.subscribe(toAnalyticEvents: self)
        let policy = YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
        self.sessionManager?.setPlayerPolicyDelegate(policy)

        do {
            let yospacePlayer = YospacePlayer(bitmovinYospacePlayer: self)
            try self.sessionManager?.setVideoPlayer(yospacePlayer)
            self.yospacePlayer = yospacePlayer
        } catch {
            handleError(code: YospaceErrorCode.invalidPlayer.rawValue, message: "Invalid video player added to session manger")
        }

        switch sessionManager.initialisationState {
        case .notInitialised:
            handleError(code: YospaceErrorCode.notIntialised.rawValue, message: "Not Intialized")
            NSLog("Not initialized url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
        case .initialisedNoAnalytics:
            handleError(code: YospaceErrorCode.noAnalytics.rawValue, message: "No analytics")
            NSLog("No Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
        case .initialisedWithAnalytics:
            NSLog("With Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")

            let sourceConfig = SourceConfiguration()
            sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: stream.streamSource())))
            load(sourceConfiguration: sourceConfig)
        default:
            break
        }
    }

    public func operationDidFailWithError(_ error: Error) {
        handleError(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error")
    }

}

// MARK: - PlayerListener
extension BitmovinYospacePlayer: PlayerListener {

    public func onPlay(_ event: PlayEvent) {
        NSLog("On Play")
        if sessionStatus == .notInitialised || sessionStatus == .ready {
            sessionStatus = .playing
            let dictionary = [kYoPlayheadKey: currentTime]
            self.notify(dictionary: dictionary, name: YoPlaybackStartedNotification)
        } else {
            let dictionary = [kYoPlayheadKey: currentTime]
            self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
        }
        for listener: PlayerListener in listeners {
            listener.onPlay?(event)
        }
    }

    public func onPaused(_ event: PausedEvent) {
        NSLog("On Paused")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackPausedNotification)
        for listener: PlayerListener in listeners {
            listener.onPaused?(event)
        }
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        NSLog("On Source Unloaded")
        if sessionStatus != .notInitialised {
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetSessionManager()
        }
        for listener: PlayerListener in listeners {
            listener.onSourceUnloaded?(event)
        }
    }

    public func onStallStarted(_ event: StallStartedEvent) {
        NSLog("On Stall Started")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackStalledNotification)
        for listener: PlayerListener in listeners {
            listener.onStallStarted?(event)
        }
    }

    public func onStallEnded(_ event: StallEndedEvent) {
        NSLog("On Stall Ended")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
        for listener: PlayerListener in listeners {
            listener.onStallEnded?(event)
        }
    }

    public func onError(_ event: ErrorEvent) {
        NSLog("On Error")
        for listener: PlayerListener in listeners {
            listener.onError?(event)
        }
    }

    public func onReady(_ event: ReadyEvent) {
        NSLog("On Ready")
        if sessionStatus == .notInitialised {
            sessionStatus = .ready
            self.notify(dictionary: Dictionary(), name: YoPlaybackReadyNotification)
        }
        for listener: PlayerListener in listeners {
            listener.onReady?(event)
        }
    }

    public func onMuted(_ event: MutedEvent) {
        let dictionary = [kYoMutedKey: Bool(self.isMuted)]
        self.notify(dictionary: dictionary, name: YoPlaybackVolumeChangedNotification)
        for listener: PlayerListener in listeners {
            listener.onMuted?(event)
        }
    }

    public func onUnmuted(_ event: UnmutedEvent) {
        let dictionary = [kYoMutedKey: Bool(self.isMuted)]
        self.notify(dictionary: dictionary, name: YoPlaybackVolumeChangedNotification)
        for listener: PlayerListener in listeners {
            listener.onUnmuted?(event)
        }
    }

    public func onMetadata(_ event: MetadataEvent) {
        let meta = YSTimedMetadata.createFromMetadata(event: event)
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
            let dictionary = [kYoMetadataKey: meta]
            self.notify(dictionary: dictionary, name: YoTimedMetadataNotification)
        }
        for listener: PlayerListener in listeners {
            listener.onMetadata?(event)
        }
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        let dictionary = [kYoPlayheadKey: Int(currentTime), kYoCompletedKey: Int(truncating: true)]
        self.notify(dictionary: dictionary, name: YoPlaybackEndedNotification)

        for listener: PlayerListener in listeners {
            listener.onPlaybackFinished?(event)
        }
    }

    func notify(dictionary: [String: Any], name: String) {
        NSLog("Firing %@ Notification", name)
        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self.yospacePlayer, userInfo: dictionary)
        })
    }

    public func onDurationChanged(_ event: DurationChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onDurationChanged?(DurationChangedEvent(duration: duration))
        }
    }

    public func onTimeChanged(_ event: TimeChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onTimeChanged?(TimeChangedEvent(currentTime: currentTime))
        }
    }

    public func onSeek(_ event: SeekEvent) {
        for listener: PlayerListener in listeners {
            listener.onSeek?(event)
        }
    }

    public func onDestroy(_ event: DestroyEvent) {
        for listener: PlayerListener in listeners {
            listener.onDestroy?(event)
        }
    }

    public func onEvent(_ event: PlayerEvent) {
        for listener: PlayerListener in listeners {
            listener.onEvent?(event)
        }
    }

    public func onAdClicked(_ event: AdClickedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdClicked?(event)
        }
    }

    public func onAdSkipped(_ event: AdSkippedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdSkipped?(event)
        }
    }

    public func onAdStarted(_ event: AdStartedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdStarted?(event)
        }
    }

    public func onCastStart(_ event: CastStartEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastStart?(event)
        }
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdFinished?(event)
        }
    }

    public func onSeeked(_ event: SeekedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSeeked?(event)
        }
    }

    public func onTimeShift(_ event: TimeShiftEvent) {
        for listener: PlayerListener in listeners {
            listener.onTimeShift?(event)
        }
    }

    public func onAdScheduled(_ event: AdScheduledEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdScheduled?(event)
        }
    }

    public func onAudioAdded(_ event: AudioAddedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAudioAdded?(event)
        }
    }

    public func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onVideoDownloadQualityChanged?(event)
        }
    }

    public func onCastPlaying(_ event: CastPlayingEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastPlaying?(event)
        }
    }

    public func onCastStarted(_ event: CastStartedEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastStarted?(event)
        }
    }

    public func onCastStopped(_ event: CastStoppedEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastStopped?(event)
        }
    }

    public func onCastAvailable(_ event: CastAvailableEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastAvailable?(event)
        }
    }

    public func onCastPlaybackFinished(_ event: CastPlaybackFinishedEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastPlaybackFinished?(event)
        }
    }

    public func onCastPaused(_ event: CastPausedEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastPaused?(event)
        }
    }

    public func onTimeShifted(_ event: TimeShiftedEvent) {
        for listener: PlayerListener in listeners {
            listener.onTimeShifted?(event)
        }
    }

    public func onAudioChanged(_ event: AudioChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAudioChanged?(event)
        }
    }

    public func onAudioRemoved(_ event: AudioRemovedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAudioRemoved?(event)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSourceLoaded?(event)
        }
    }

    public func onSubtitleAdded(_ event: SubtitleAddedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleAdded?(event)
        }
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(event)
        }
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(event)
        }
    }

    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
        for listener: PlayerListener in listeners {
            listener.onAdManifestLoaded?(event)
        }
    }

    public func onCastTimeUpdated(_ event: CastTimeUpdatedEvent) {
        for listener: PlayerListener in listeners {
            listener.onCastTimeUpdated?(event)
        }
    }

    public func onSubtitleRemoved(_ event: SubtitleRemovedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleRemoved?(event)
        }
    }

    public func onSubtitleChanged(_ event: SubtitleChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleChanged?(event)
        }
    }

    public func onCueEnter(_ event: CueEnterEvent) {
        for listener: PlayerListener in listeners {
            listener.onCueEnter?(event)
        }
    }

    public func onCueExit(_ event: CueExitEvent) {
        for listener: PlayerListener in listeners {
            listener.onCueExit?(event)
        }
    }

    public func onDvrWindowExceeded(_ event: DvrWindowExceededEvent) {
        for listener: PlayerListener in listeners {
            listener.onDvrWindowExceeded?(event)
        }
    }

    public func onDownloadFinished(_ event: DownloadFinishedEvent) {
        for listener: PlayerListener in listeners {
            listener.onDownloadFinished?(event)
        }
    }

    public func onRenderFirstFrame(_ event: RenderFirstFrameEvent) {
        for listener: PlayerListener in listeners {
            listener.onRenderFirstFrame?(event)
        }
    }

    public func onSourceWillUnload(_ event: SourceWillUnloadEvent) {
        for listener: PlayerListener in listeners {
            listener.onSourceWillUnload?(event)
        }
    }

    public func onVideoSizeChanged(_ event: VideoSizeChangedEvent) {
        for listener: PlayerListener in listeners {
            listener.onVideoSizeChanged?(event)
        }
    }

    public func onConfigurationUpdated(_ event: ConfigurationUpdatedEvent) {
        for listener: PlayerListener in listeners {
            listener.onConfigurationUpdated?(event)
        }
    }
}
