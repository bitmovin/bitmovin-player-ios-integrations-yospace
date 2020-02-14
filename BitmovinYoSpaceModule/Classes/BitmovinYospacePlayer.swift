import UIKit
import BitmovinPlayer
import Yospace

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

open class BitmovinYospacePlayer: BitmovinPlayer {
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
    public private(set) var timeline: AdTimeline?
    var timebase: TimeInterval = 0
    var realAdBreaks: [YSAdBreak] = []
    var truexConfiguration: TruexConfiguration?
    var trueXRendering = false
    var dateRangeEmitter: DateRangeEmitter?
    var activeAdBreak: AdBreak?
    var activeAd: Ad?

    #if os(iOS)
    var truexAdRenderer: BitmovinTruexAdRenderer?
    #endif

    var adBreaks: [YSAdBreak] {
        get {
            return realAdBreaks
        }
        set (adBreaks) {
            realAdBreaks = adBreaks
            self.timeline = AdTimeline(breaks: adBreaks)
            self.handTimelineUpdated()
        }
    }

    // pass along the BitmovinYospacePlayerPolicy to the internal yospacePlayerPolicy which will be called by by our sessionManager
    public var playerPolicy: BitmovinYospacePlayerPolicy? {
        set (playerPolicy) {
            self.yospacePlayerPolicy?.playerPolicy = playerPolicy
        }
        get {
            return self.yospacePlayerPolicy?.playerPolicy
        }
    }

    open override var duration: TimeInterval {
        return super.duration - self.adBreaks.reduce(0) {$0 + $1.adBreakDuration()}
    }

    open override var currentTime: TimeInterval {
        if isAd {
            if isLive {
                return super.currentTime - (activeAd?.relativeStart ?? 0)
            } else {
                return timeline?.adTime(time: super.currentTime) ?? super.currentTime
            }
        } else {
            return timeline?.absoluteToRelative(time: super.currentTime) ?? super.currentTime
        }
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
        self.yospaceConfiguration = yospaceConfiguration
        super.init(configuration: configuration)
        sessionStatus = .notInitialised
        super.add(listener: self)
        self.yospacePlayerPolicy = YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
        self.dateRangeEmitter = DateRangeEmitter(player: self)
        updateLoggingVisibility(isLoggingEnabled: yospaceConfiguration?.debug ?? false)
    }

    open override func destroy() {
        resetYospaceSession()
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
    open func load(sourceConfiguration: SourceConfiguration, yospaceSourceConfiguration: YospaceSourceConfiguration? = nil, truexConfiguration: TruexConfiguration? = nil) {
        #if os(iOS)
        if let truexConfiguration = truexConfiguration {
            self.truexConfiguration = truexConfiguration
            self.truexAdRenderer = BitmovinTruexAdRenderer(bitmovinPlayer: self,
                                                           view: truexConfiguration.view,
                                                           userId: truexConfiguration.userId,
                                                           vastConfigUrl: truexConfiguration.vastConfigUrl)
        } else {
            self.truexConfiguration = nil
            self.truexAdRenderer = nil
        }
        #endif

        var logMessage = "Load: "
        if let url = sourceConfiguration.firstSourceItem?.hlsSource?.url {
            logMessage.append("Source=\(url.absoluteString)")
        }
        if let yospaceSourceConfiguration = yospaceSourceConfiguration {
            logMessage.append(", YospaceAssetType=\(yospaceSourceConfiguration.yospaceAssetType.rawValue)")
            logMessage.append(", YospaceRetry=\(yospaceSourceConfiguration.retryExcludingYospace)")
        }
        if let truexConfiguration = truexConfiguration {
            logMessage.append(", TruexUserId=\(truexConfiguration.userId)")
            logMessage.append(", TruexVastConfigUrl=\(truexConfiguration.vastConfigUrl)")
        }
        BitLog.d(logMessage)

        resetYospaceSession()
        self.yospaceSourceConfiguration = yospaceSourceConfiguration
        self.sourceConfiguration = sourceConfiguration
        let yospaceProperties = YSSessionProperties()

        if let timeout = yospaceConfiguration?.timeout {
            yospaceProperties.timeout = timeout
        }

        if let pollingInterval = yospaceConfiguration?.pollingInterval {
            yospaceProperties.targetDuration = pollingInterval
        }

        if let userAgent = yospaceConfiguration?.userAgent {
            yospaceProperties.analyticsUserAgent = userAgent
            yospaceProperties.redirectUserAgent = userAgent
        }

        if yospaceConfiguration?.debug != nil && yospaceConfiguration?.debug == true {
            let combined = YSEDebugFlags(rawValue: YSEDebugFlags.DEBUG_ALL.rawValue)
            YSSessionProperties.add(_:combined!)
        }

        guard let url: URL = self.sourceConfiguration?.firstSourceItem?.hlsSource?.url else {
            handleError(code: YospaceErrorCode.invalidSource.rawValue, message: "Invalid source provided. Yospace URL must be HLS")
            return
        }

        guard let yospaceSourceConfiguration = yospaceSourceConfiguration else {
            load(sourceConfiguration: sourceConfiguration)
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

    open override func unload() {
        BitLog.d("Unload: ")
        super.unload()
    }

    // MARK: - playback methods
    open override func pause() {
        if let manager = self.sessionManager {
            if !manager.canPause() {
                return
            }
        }
        super.pause()
    }

    open override func seek(time: TimeInterval) {
        if let manager = self.sessionManager {
            let seekTime = manager.willSeek(to: time)
            let absoluteSeekTime = timeline?.relativeToAbsolute(time: seekTime) ?? seekTime
            BitLog.d("Seeking: Original: \(time) Manager: \(seekTime) Absolute \(absoluteSeekTime)")
            super.seek(time: absoluteSeekTime)
        } else {
            BitLog.d("Seeking to: \(time)")
            super.seek(time: time)
        }
    }

    func forceSeek(time: TimeInterval) {
        BitLog.d("Seeking to: \(time)")
        super.seek(time: time)
    }

    func handleTrueXAdFree() {
        for listener: YospaceListener in yospaceListeners {
            listener.onTrueXAdFree()
        }
    }

    // MARK: - event handling
    open override func add(listener: PlayerListener) {
        listeners.append(listener)
    }

    open override func remove(listener: PlayerListener) {
        listeners = listeners.filter { $0 !== listener }
    }

    public func add(yospaceListener: YospaceListener) {
        yospaceListeners.append(yospaceListener)
    }

    public func remove(yospaceListener: YospaceListener) {
        yospaceListeners = yospaceListeners.filter { $0 !== yospaceListener }
    }

    public func clickThroughPressed() {
        sessionManager?.linearClickThroughDidOccur()
    }

    func resetYospaceSession() {
        self.sessionManager?.shutdown()
        self.sessionManager = nil
        self.yospaceStream = nil
        self.adBreaks = []
        sessionStatus = .notInitialised
        adPlaying = false
        trueXRendering = false
        #if os(iOS)
        self.truexAdRenderer?.resetAdRenderer()
        #endif
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

    func handleError(code: UInt, message: String) {
        for listener: YospaceListener in yospaceListeners {
            listener.onYospaceError(event: ErrorEvent(code: code, message: message))
        }
    }

    func handTimelineUpdated() {
        guard let timeline = self.timeline else {
            return
        }

        for listener: YospaceListener in yospaceListeners {
            listener.onTimelineChanged(event: AdTimelineChangedEvent(name: "TimelineChanged",
                                                                     timestamp: NSDate().timeIntervalSince1970,
                                                                     timeline: timeline))
        }
    }

    open override func skipAd() {
        if sessionStatus != .notInitialised {
            guard sessionManager != nil else {
                return
            }

            let adBreak: AdBreak? = getActiveAdBreak()
            if let currentBreak = adBreak {
                super.seek(time: currentBreak.absoluteEnd)
            }
        } else {
            super.skipAd()
        }
    }

    open override var isAd: Bool {
        if sessionStatus != .notInitialised {
            return adPlaying
        } else {
            return super.isAd
        }
    }

    open func currentTimeWithAds() -> TimeInterval {
        return super.currentTime
    }

    public func durationWithAds() -> TimeInterval {
        return super.duration
    }

    public func getActiveAdBreak() -> AdBreak? {
        return activeAdBreak
    }

    public func getActiveAd() -> Ad? {
        return activeAd
    }

    private func updateLoggingVisibility(isLoggingEnabled: Bool) {
        if isLoggingEnabled {
            BitLog.enable()
        } else {
            BitLog.disable()
        }
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer: YSAnalyticObserver {
    public func advertBreakDidStart(_ adBreak: YSAdBreak) {
        #if os(iOS)
        if truexAdRenderer != nil {
            if truexAdRenderer!.adFree {
                BitLog.d("Skipping Ad Break due to TrueX ad free experience")
                super.seek(time: adBreak.adBreakEnd())
            } else {
                BitLog.d("Rendering TrueX Ad")
                trueXRendering = truexAdRenderer!.renderTruex(adverts: adBreak.adverts())
                BitLog.d("TrueX Ad Rendered - \(trueXRendering)")
            }
        }
        #endif
        
        let bitmovinAdBreak = createAdBreakFromYSAdBreak(adBreak)
        let adBreakStartEvent = YospaceAdBreakStartedEvent(adBreak: bitmovinAdBreak)

        for yospaceAdvert in adBreak.adverts() {
            guard let advert = yospaceAdvert as? YSAdvert else {
                continue
            }
            bitmovinAdBreak.appendAd(ad: createAdFromAdvert(advert))
        }

        activeAdBreak = bitmovinAdBreak

        if !trueXRendering {
            BitLog.d("Yospace AdBreakStartedEvent")
            for listener: PlayerListener in listeners {
                listener.onAdBreakStarted?(adBreakStartEvent)
            }
        }

    }

    public func advertBreakDidEnd(_ adBreak: YSAdBreak) {
        if !trueXRendering {
            BitLog.d("Yospace AdBreakFinishedEvent")
            for listener: PlayerListener in listeners {
                listener.onAdBreakFinished?(AdBreakFinishedEvent())
            }
        }
        activeAdBreak = nil
        trueXRendering = false

    }

    public func advertDidStart(_ advert: YSAdvert) -> [Any]? {
        activeAd = createAdFromAdvert(advert)
        
        if !trueXRendering {
            adPlaying = true

            let adStartedEvent: YospaceAdStartedEvent = YospaceAdStartedEvent(clickThroughUrl: activeAd?.clickThroughUrl,
                                                                clientType: .IMA, indexInQueue: 0,
                                                                duration: advert.advertDuration(),
                                                                timeOffset: advert.advertStart() + timebase,
                                                                skipOffset: 1,
                                                                position: "0")

            BitLog.d("Yospace AdStartedEvent")
            for listener: PlayerListener in listeners {
                listener.onAdStarted?(adStartedEvent)
            }
        }
        return []
    }

    public func advertDidEnd(_ advert: YSAdvert) {
        adPlaying = false
        if !trueXRendering {
            BitLog.d("Yospace AdFinishedEvent")
            for listener: PlayerListener in listeners {
                listener.onAdFinished?(AdFinishedEvent())
            }
        }
        activeAd = nil
        trueXRendering = false
    }

    public func trackingEventDidOccur(_ event: YSETrackingEvent, for advert: YSAdvert) {
        BitLog.d("Tracking Event Did Occur %@ \(YospaceUtil.trackingEventString(event: event))")
    }

    public func linearClickThroughDidOccur(_ linearCreative: YSLinearCreative) {
        BitLog.d("Yospace AdClickedEvent")
        for listener: PlayerListener in listeners {
            listener.onAdClicked?(AdClickedEvent(clickThroughUr: linearCreative.linearClickthroughURL()))
        }
    }

    public func timelineUpdateReceived(_ vmap: String) {
        if let timeline = self.yospaceStream?.timeline() as? [YSAdBreak] {
            BitLog.d("TimelineUpdateReceived: \(timeline.count)")
            self.adBreaks = timeline
        }
    }

    private func createAdFromAdvert(_ advert: YSAdvert) -> Ad {
        var clickThroughUrl: URL? = nil
        if advert.linearCreativeElement().linearClickthroughURL() != nil {
            clickThroughUrl = advert.linearCreativeElement().linearClickthroughURL()!
        }

        return Ad(identifier: advert.advertIdentifier(),
        absoluteStart: advert.advertStart() + timebase,
        absoluteEnd: advert.advertEnd() + timebase,
        duration: advert.advertDuration(),
        relativeStart: currentTimeWithAds(),
        hasInteractiveUnit: advert.hasLinearInteractiveUnit(),
        clickThroughUrl: clickThroughUrl)
    }
    
    private func createAdBreakFromYSAdBreak(_ ysAdBreak: YSAdBreak) -> AdBreak {
        return AdBreak(identifier: ysAdBreak.adBreakIdentifier(),
                                      absoluteStart: ysAdBreak.adBreakStart() + timebase,
                                      absoluteEnd: ysAdBreak.adBreakEnd() + timebase,
                                      duration: ysAdBreak.adBreakDuration(),
                                      relativeStart: ysAdBreak.adBreakStart())
    }

}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer: YSSessionManagerObserver {
    public func sessionDidInitialise(_ sessionManager: YSSessionManager, with stream: YSStream) {
        self.sessionManager = sessionManager
        self.yospaceStream = stream
        if let timeline = self.yospaceStream?.timeline() as? [YSAdBreak] {
            BitLog.d("Initial Ad Breaks Received: \(timeline.count)")
            self.adBreaks = timeline
        }

        self.sessionManager?.subscribe(toAnalyticEvents: self)
        let policy = self.yospacePlayerPolicy ?? YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
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
            BitLog.e("Not initialized url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                self.onWarning(WarningEvent(code: YospaceErrorCode.notIntialised.rawValue, message: "Not initialized"))
                load(sourceConfiguration: sourceConfiguration)
            } else {
                handleError(code: YospaceErrorCode.notIntialised.rawValue, message: "Not Intialized")
            }
        case .initialisedNoAnalytics:
            BitLog.d("No Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                self.onWarning(WarningEvent(code: YospaceErrorCode.noAnalytics.rawValue, message: "No analytics"))
                load(sourceConfiguration: sourceConfiguration)
            } else {
                handleError(code: YospaceErrorCode.noAnalytics.rawValue, message: "No Analytics")
            }

        case .initialisedWithAnalytics:
            BitLog.d("With Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            let sourceConfig = SourceConfiguration()
            sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: stream.streamSource())))
            if let drmConfiguration: DRMConfiguration = self.sourceConfiguration?.firstSourceItem?.drmConfigurations?.first {
                sourceConfig.firstSourceItem?.add(drmConfiguration: drmConfiguration)
            }
            load(sourceConfiguration: sourceConfig)
        default:
            break
        }
    }

    public func operationDidFailWithError(_ error: Error) {
        if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
            BitLog.w("Attempting to playback the stream url without Yospace")
            self.onWarning(WarningEvent(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error"))
            load(sourceConfiguration: sourceConfiguration)
        } else {
            handleError(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error")
        }
    }

}

// MARK: - PlayerListener
extension BitmovinYospacePlayer: PlayerListener {

    public func onPlay(_ event: PlayEvent) {
        for listener: PlayerListener in listeners {
            listener.onPlay?(PlayEvent(time: currentTime))
        }
    }

    public func onPlaying(_ event: PlayingEvent) {
        if sessionStatus == .notInitialised || sessionStatus == .ready {
            sessionStatus = .playing
            let dictionary = [kYoPlayheadKey: currentTimeWithAds()]
            self.notify(dictionary: dictionary, name: YoPlaybackStartedNotification)
        } else {
            let dictionary = [kYoPlayheadKey: currentTimeWithAds()]
            self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
        }
        for listener: PlayerListener in listeners {
            listener.onPlaying?(PlayingEvent(time: currentTime))
        }
    }

    public func onPaused(_ event: PausedEvent) {
        let dictionary = [kYoPlayheadKey: currentTimeWithAds()]
        self.notify(dictionary: dictionary, name: YoPlaybackPausedNotification)
        for listener: PlayerListener in listeners {
            listener.onPaused?(PausedEvent(time: currentTime))
        }
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        if sessionStatus != .notInitialised {
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetYospaceSession()
        }
        for listener: PlayerListener in listeners {
            listener.onSourceUnloaded?(event)
        }
    }

    public func onStallStarted(_ event: StallStartedEvent) {
        let dictionary = [kYoPlayheadKey: currentTimeWithAds()]
        self.notify(dictionary: dictionary, name: YoPlaybackStalledNotification)
        for listener: PlayerListener in listeners {
            listener.onStallStarted?(event)
        }
    }

    public func onStallEnded(_ event: StallEndedEvent) {
        let dictionary = [kYoPlayheadKey: currentTimeWithAds()]
        self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
        for listener: PlayerListener in listeners {
            listener.onStallEnded?(event)
        }
    }

    public func onError(_ event: ErrorEvent) {
        for listener: PlayerListener in listeners {
            listener.onError?(event)
        }
        let error = NSError(domain: "Bitmovin", code: Int(event.code), userInfo: [NSLocalizedDescriptionKey: event.message])
        var time = currentTimeWithAds()
        if time.isInfinite || time.isNaN {
            time = 0
        }
        let dictionary = [kYoPlayheadKey: Int(time), kYoErrorKey: error] as [String: Any]
        self.notify(dictionary: dictionary, name: YoPlaybackErrorNotification)
    }

    public func onWarning(_ event: WarningEvent) {
        for listener: PlayerListener in listeners {
            listener.onWarning?(event)
        }
    }

    public func onReady(_ event: ReadyEvent) {
        self.timebase = self.currentTimeWithAds()

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
        if yospaceSourceConfiguration?.yospaceAssetType == YospaceAssetType.linear {
            if event.metadataType == BMPMetadataType.ID3 {
                trackId3(event)
            } else if event.metadataType == BMPMetadataType.daterange {
                trackDateRange(event)
            }
        }
        for listener: PlayerListener in listeners {
            listener.onMetadata?(event)
        }
    }

    public func onMetadataParsed(_ event: MetadataParsedEvent) {
    }

    func trackId3(_ event: MetadataEvent) {
        let meta = YSTimedMetadata.createFromMetadata(event: event)
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
            let dictionary = [kYoMetadataKey: meta]
            self.notify(dictionary: dictionary, name: YoTimedMetadataNotification)
        }

    }

    func trackDateRange(_ event: MetadataEvent) {
        self.dateRangeEmitter?.trackEmsg(event)
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        let dictionary = [kYoPlayheadKey: Int(currentTimeWithAds()), kYoCompletedKey: Int(truncating: true)]
        self.notify(dictionary: dictionary, name: YoPlaybackEndedNotification)

        for listener: PlayerListener in listeners {
            listener.onPlaybackFinished?(event)
        }
    }

    func notify(dictionary: [String: Any], name: String) {
        BitLog.d("Yospace sending \(name)")
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
            let position = timeline?.absoluteToRelative(time: event.position) ?? event.position
            let seekTarget = timeline?.absoluteToRelative(time: event.seekTarget) ?? event.seekTarget
            listener.onSeek?(SeekEvent(position: position, seekTarget: seekTarget))
        }
    }

    /**
     Unmodified eevents, passing thought to registered listeners
     */
    public func onSeeked(_ event: SeekedEvent) {
        for listener: PlayerListener in listeners {
            listener.onSeeked?(event)
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
        BitLog.d("onAdClicked: ")
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
        BitLog.d("onAdStarted: ")
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
        BitLog.d("onAdFinished: ")
        for listener: PlayerListener in listeners {
            listener.onAdFinished?(event)
        }
    }

    public func onTimeShift(_ event: TimeShiftEvent) {
        for listener: PlayerListener in listeners {
            listener.onTimeShift?(event)
        }
    }

    public func onAdScheduled(_ event: AdScheduledEvent) {
        BitLog.d("onAdScheduled: ")
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
        BitLog.d("onAdBreakStarted: ")
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(event)
        }
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        BitLog.d("onAdBreakFinished: ")
        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(event)
        }
    }

    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
        BitLog.d("onAdManifestLoaded: ")
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
