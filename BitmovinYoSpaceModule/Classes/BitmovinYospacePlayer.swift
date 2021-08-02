import UIKit
import BitmovinPlayer
import Yospace

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

open class BitmovinYospacePlayer: Player {
    // MARK: - Bitmovin Yospace Player attributes
    var sessionManager: YSSessionManager?
    var yospaceStream: YSStream?
    var sessionStatus: SessionStatus = .notInitialised
    var yospaceSourceConfiguration: YospaceSourceConfiguration?
    var yospaceConfiguration: YospaceConfiguration?
    var integrationConfiguration: IntegrationConfiguration?
    var sourceConfiguration: SourceConfiguration?
    var listeners: [PlayerListener] = []
    var yospacePlayerPolicy: YospacePlayerPolicy?
    var yospacePlayer: YospacePlayer?
    var yospaceListeners: [YospaceListener] = []
    public private(set) var timeline: AdTimeline?
    var realAdBreaks: [YSAdBreak] = []
    var truexConfiguration: TruexConfiguration?
    var dateRangeEmitter: DateRangeEmitter?
    var playheadNormalizer: PlayheadNormalizer?
    var receivedFirstPlayhead: Bool = false
    var integrationListeners: [IntegrationListener] = []
    var activeAdBreak: YospaceAdBreak?
    var activeAd: YospaceAd?
    var liveAdPaused = false

    #if os(iOS)
    private var truexRenderer: BitmovinTruexRenderer?
    #endif

    var adBreaks: [YSAdBreak] {
        get {
            return realAdBreaks
        }
        set (adBreaks) {
            realAdBreaks = adBreaks
            self.timeline = AdTimeline(adBreaks: adBreaks)
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
            // Return ad time
            return super.currentTime - (activeAd?.absoluteStart ?? 0.0)
        } else if isLive {
            // Return absolute time
            return super.currentTime
        } else /* VOD */ {
            // Return relative time; fallback to absolute time
            return timeline?.absoluteToRelative(time: super.currentTime) ?? super.currentTime
        }
    }

    public var suppressAnalytics: Bool = false {
        didSet {
            sessionManager?.suppressAnalytics(suppressAnalytics)
        }
    }

    // MARK: - initializer
    /**
     Initialize a new Bitmovin Yospace player for SSAI with Yospace
     
     **!! The BitmovinYospacePlayer will only be able to play Yospace streams. It will error out on all other streams. Please add a YospaceListener to be notified of these errors !!**
     
     - Parameters:
     - configuration: Traditional PlayerConfiguration used by Bitmovin
     - yospaceConfiguration: YospaceConfiguration object that changes the behavior of the internal Yospace AD Management SDK
     */
    public init(configuration: PlayerConfiguration, yospaceConfiguration: YospaceConfiguration? = nil, integrationConfiguration: IntegrationConfiguration? = nil) {
        self.yospaceConfiguration = yospaceConfiguration
        self.integrationConfiguration = integrationConfiguration
        super.init(configuration: configuration)
        sessionStatus = .notInitialised
        super.add(listener: self)
        
        BitLog.isEnabled = yospaceConfiguration?.isDebugEnabled ?? false
        self.yospacePlayerPolicy = YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
        
        // For the immediate, only utilizing the normalizer inside the DateEmitter, as that solves the most pressing problems
        // We can potentially expand to normalizing all time values post-validation
        // Note - we may need to initialize the normalizer before adding listeners here, to give event handler precedence to the normalizer
        if let integrationConfiguration = self.integrationConfiguration {
            // Using playhead normalization is opt-in
            if (integrationConfiguration.enablePlayheadNormalization) {
                self.playheadNormalizer = PlayheadNormalizer(player: self, eventDelegate: self)
            }
        }
        self.dateRangeEmitter = DateRangeEmitter(player: self, normalizer: playheadNormalizer)
    }

    open override func destroy() {
        resetYospaceSession()
        integrationListeners.removeAll()
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
            self.truexRenderer = BitmovinTruexRenderer(configuration: truexConfiguration, eventDelegate: self)
        } else {
            self.truexConfiguration = nil
            self.truexRenderer = nil
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
            if !truexConfiguration.userId.isEmpty {
                logMessage.append(", TruexUserId=\(truexConfiguration.userId)")
            }
            if !truexConfiguration.vastConfigUrl.isEmpty {
                logMessage.append(", TruexVastConfigUrl=\(truexConfiguration.vastConfigUrl)")
            }
        }
        BitLog.d(logMessage)

        resetYospaceSession()
        self.yospaceSourceConfiguration = yospaceSourceConfiguration
        self.sourceConfiguration = sourceConfiguration

        let yospaceProperties = YSSessionProperties()
        yospaceProperties.suppressAllAnalytics = true

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

        if yospaceConfiguration?.isDebugEnabled == true {
            let combined = YSEDebugFlags(rawValue: YSEDebugFlags.DEBUG_ALL.rawValue)
            YSSessionProperties.add(_:combined!)
        }

        guard let url: URL = self.sourceConfiguration?.firstSourceItem?.hlsSource?.url else {
            onError(ErrorEvent(code: YospaceErrorCode.invalidSource.rawValue, message: "Invalid source provided. Yospace URL must be HLS"))
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

    open func forceSeek(time: TimeInterval) {
        BitLog.d("Seeking to: \(time)")
        super.seek(time: time)
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
    
    public func add(integrationListener: IntegrationListener) {
        integrationListeners.append(integrationListener)
    }

    public func remove(integrationListener: IntegrationListener) {
        integrationListeners = integrationListeners.filter { $0 !== integrationListener }
    }

    public func linearClickThroughDidOccur() {
        sessionManager?.linearClickThroughDidOccur()
    }

    public func companionClickThroughDidOccur(companionId: String) {
        sessionManager?.companionClickThroughDidOccur(companionId)
    }

    public func companionRendered(companionId: String) {
        sessionManager?.companionEvent("creativeView", didOccur: companionId)
    }

    func resetYospaceSession() {
        self.sessionManager?.shutdown()
        self.sessionManager = nil
        self.yospaceStream = nil
        self.adBreaks = []
        self.activeAd = nil
        self.activeAdBreak = nil
        liveAdPaused = false
        sessionStatus = .notInitialised
        receivedFirstPlayhead = false
        #if os(iOS)
        self.truexRenderer?.stopRenderer()
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

            let adBreak: YospaceAdBreak? = getActiveAdBreak()
            if let currentBreak = adBreak {
                super.seek(time: currentBreak.absoluteEnd)
            }
        } else {
            super.skipAd()
        }
    }

    open override var isAd: Bool {
        if sessionStatus != .notInitialised {
            return activeAd != nil
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

    public func getActiveAdBreak() -> YospaceAdBreak? {
        return activeAdBreak
    }

    public func getActiveAd() -> YospaceAd? {
        return activeAd
    }
}

// MARK: - PlayheadNormalizerEventDelegate
extension BitmovinYospacePlayer: PlayheadNormalizerEventDelegate {
    func normalizingStarted() {
        for listener in integrationListeners {
            listener.onPlayheadNormalizingStarted()
        }
    }
    
    func normalizingFinished() {
        for listener in integrationListeners {
            listener.onPlayheadNormalizingFinished()
        }
    }
}

// MARK: - TruexAdRendererEventDelegate
extension BitmovinYospacePlayer: TruexAdRendererEventDelegate {

    func skipTruexAd() {
        BitLog.d("YoSpace analytics unsuppressed")
        sessionManager?.suppressAnalytics(false)

        // Seek to end of TrueX ad filler
        if let advert = activeAd {
            BitLog.d("Skipping TrueX filler")
            forceSeek(time: advert.absoluteEnd)
        }

        BitLog.d("Resuming player")
        play()
    }

    func skipAdBreak() {
        BitLog.d("YoSpace analytics unsuppressed")
        sessionManager?.suppressAnalytics(false)

        // Seek to end of ad break
        if let adBreak = activeAdBreak {
            BitLog.d("Skipping ad break")
            // Add increment of 0.25 to make sure we land back in main content
            forceSeek(time: adBreak.absoluteEnd + 0.25)
        }

        BitLog.d("Resuming player")
        play()
    }

    func sessionAdFree() {
        BitLog.d("Session ad free")
        for listener in yospaceListeners {
            listener.onTrueXAdFree()
        }
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer: YSAnalyticObserver {
    public func advertBreakDidStart(_ adBreak: YSAdBreak?) {
        BitLog.d("YoSpace advertBreakDidStart: ")

        if let adBreak = adBreak, !isLive {
            handleAdBreakEvent(adBreak)
        }
    }

    public func advertDidStart(_ advert: YSAdvert) -> [Any]? {
        BitLog.d("YoSpace advertDidStart")

        if isLive, activeAdBreak == nil, let currentAdBreak = yospaceStream?.currentAdvertBreak() {
            handleAdBreakEvent(currentAdBreak)
        }

        activeAd = createActiveAd(advert: advert)

        #if os(iOS)
        if let renderer = truexRenderer, advert.hasLinearInteractiveUnit() {
            BitLog.d("TrueX ad found: \(advert)")

            // Suppress analytics in order for YoSpace TrueX tracking to work
            BitLog.d("YoSpace analytics suppressed")
            sessionManager?.suppressAnalytics(true)
            BitLog.d("Pausing player")
            super.pause()

            let adBreakPosition: YospaceAdBreakPosition = activeAdBreak?.relativeStart == 0 ? .preroll : .midroll
            renderer.renderTruexAd(advert: advert, adBreakPosition: adBreakPosition)
        }
        #endif

        let companionAds = (advert.companionCreativeElements() as? [YSCompanionCreative])?.map { (creative: YSCompanionCreative) -> CompanionAd in

            let resource: CompanionAdResource

            if let creativeElement = creative.creativeElement() {
                let html = String(decoding: creativeElement, as: UTF8.self)
                resource = CompanionAdResource(source: html, type: .html)
            } else {
                let source = creative.creativeSource()?.absoluteString
                resource = CompanionAdResource(source: source, type: .static)
            }

            return CompanionAd(
                id: creative.companionIdentifier(),
                adSlotId: creative.adSlotIdentifier(),
                width: creative.userInterfaceProperties().rect().width,
                height: creative.userInterfaceProperties().rect().height,
                clickThroughUrl: creative.clickThroughURL()?.absoluteString,
                resource: resource
            )
        } ?? []
        
        if let ad = activeAd {
            let adStartedEvent = YospaceAdStartedEvent(
                clickThroughUrl: ad.clickThroughUrl,
                duration: advert.advertDuration(),
                timeOffset: advert.advertStart(),
                ad: ad,
                companionAds: companionAds
            )

            BitLog.d("Emitting AdStartedEvent")
            for listener: PlayerListener in listeners {
                listener.onAdStarted?(adStartedEvent)
            }
        } else {
            BitLog.w("Advert did start but no active ad is available. Not emitting an AdStartedEvent.")
        }

        return []
    }

    public func advertDidEnd(_ advert: YSAdvert) {
        BitLog.d("YoSpace advertDidEnd")

        if activeAd == nil {
            activeAd = createActiveAd(advert: advert)
        }

        BitLog.d("Emitting AdFinishedEvent")
        for listener: PlayerListener in listeners {
            listener.onAdFinished?(AdFinishedEvent(ad: activeAd!))
        }

        activeAd = nil
    }

    public func advertBreakDidEnd(_ adBreak: YSAdBreak) {
        BitLog.d("YoSpace advertBreakDidEnd")

        if activeAdBreak == nil {
            activeAdBreak = createActiveAdBreak(adBreak: adBreak)
        }

        BitLog.d("Emitting AdBreakFinishedEvent")
        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(AdBreakFinishedEvent(adBreak: activeAdBreak!))
        }

        activeAdBreak = nil
    }

    public func trackingEventDidOccur(_ event: YSETrackingEvent, for advert: YSAdvert) {
        BitLog.d("YoSpace trackingEventDidOccur: \(YospaceUtil.trackingEventString(event: event))")

        // Send AdQuartile event
        if event == .firstQuartileEvent {
            onAdQuartile(AdQuartileEvent(quartile: .firstQuartile))
        } else if event == .midpointEvent {
            onAdQuartile(AdQuartileEvent(quartile: .midpoint))
        } else if event == .thirdQuartileEvent {
            onAdQuartile(AdQuartileEvent(quartile: .thirdQuartile))
        }
    }

    public func linearClickThroughDidOccur(_ linearCreative: YSLinearCreative) {
        BitLog.d("YoSpace linearClickThroughDidOccur")
        for listener: PlayerListener in listeners {
            listener.onAdClicked?(AdClickedEvent(clickThroughUrl: linearCreative.linearClickthroughURL()))
        }
    }

    public func timelineUpdateReceived(_ vmap: String) {
        if let timeline = self.yospaceStream?.timeline() as? [YSAdBreak] {
            BitLog.d("YoSpace timelineUpdateReceived: \(timeline.count)")
            self.adBreaks = timeline
        }
    }

    private func createActiveAd(advert: YSAdvert) -> YospaceAd {
        if let adBreakAd = (activeAdBreak?.ads.compactMap { $0 as? YospaceAd }.first { $0.identifier == advert.advertIdentifier() }) {
            return adBreakAd
        } else {
            let absoluteTime = super.currentTime
            var adAbsoluteStart: Double
            var adRelativeStart: Double

            if isLive {
                adAbsoluteStart = absoluteTime
                adRelativeStart = activeAdBreak?.relativeStart ?? adAbsoluteStart
            } else /* VOD */ {
                adAbsoluteStart = advert.advertStart()
                adRelativeStart = timeline?.absoluteToRelative(time: adAbsoluteStart) ?? adAbsoluteStart
            }

            return advert.toYospaceAd(absoluteStart: adAbsoluteStart, relativeStart: adRelativeStart)
        }
    }

    private func createActiveAdBreak(adBreak: YSAdBreak) -> YospaceAdBreak {
        let absoluteTime = super.currentTime
        var adBreakAbsoluteStart: Double
        var adBreakRelativeStart: Double

        if isLive {
            adBreakAbsoluteStart = absoluteTime
            adBreakRelativeStart = absoluteTime
        } else /* VOD */ {
            adBreakAbsoluteStart = adBreak.adBreakStart()
            adBreakRelativeStart = timeline?.absoluteToRelative(time: adBreakAbsoluteStart) ?? adBreakAbsoluteStart
        }

        return adBreak.toYospaceAdBreak(absoluteStart: adBreakAbsoluteStart, relativeStart: adBreakRelativeStart)
    }

    private func handleAdBreakEvent(_ adBreak: YSAdBreak) {
        activeAdBreak = createActiveAdBreak(adBreak: adBreak)

        BitLog.d("Emitting AdBreakStartedEvent: position=\(adBreak.adBreakPosition().rawValue)")
        let adBreakStartEvent = AdBreakStartedEvent(adBreak: activeAdBreak!)
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(adBreakStartEvent)
        }
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
            onError(ErrorEvent(code: YospaceErrorCode.invalidPlayer.rawValue, message: "Invalid video player added to session manger"))
        }

        switch sessionManager.initialisationState {
        case .notInitialised:
            BitLog.e("Not initialized url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                self.onWarning(WarningEvent(code: YospaceErrorCode.notIntialised.rawValue, message: "Not initialized"))
                load(sourceConfiguration: sourceConfiguration)
            } else {
                onError(ErrorEvent(code: YospaceErrorCode.notIntialised.rawValue, message: "Not Intialized"))
            }
        case .initialisedNoAnalytics:
            BitLog.d("No Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                self.onWarning(WarningEvent(code: YospaceErrorCode.noAnalytics.rawValue, message: "No analytics"))
                load(sourceConfiguration: sourceConfiguration)
            } else {
                onError(ErrorEvent(code: YospaceErrorCode.noAnalytics.rawValue, message: "No Analytics"))
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
            onError(ErrorEvent(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error"))
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
        liveAdPaused = isLive && isAd
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

    public func onMetadataParsed(_ event: MetadataParsedEvent) {
        // Note - this is a workaround for the intermittent missing iOS metadata issue,
        // where on start of the stream, date range metadata is not always being propagated to onMetadata
        // It is surfaced as parsed metadata, so we'll check here if it's the correct type and time, and if so,
        // parse it and track it as an ID3
        //
        // If onMetadata does fire afterwards, it will be ignored by handling in DateRangeEmitter
        if receivedFirstPlayhead == false {
            if yospaceSourceConfiguration?.yospaceAssetType == .linear {
                if let dateRangeMetadata = event.metadata as? DaterangeMetadata {
                    let metadataTime = String(format: "%.2f", dateRangeMetadata.startDate.timeIntervalSince1970)
                    let currentTime = String(format: "%.2f", self.currentTimeWithAds())
                    if metadataTime == currentTime {
                        BitLog.d("onMetadataParsed: tracking initial emsg")
                        dateRangeEmitter?.trackEmsg(event)
                    }
                }
            }
        }
        
        for listener: PlayerListener in listeners {
            listener.onMetadataParsed?(event)
        }
    }
    
    public func onMetadata(_ event: MetadataEvent) {
        if yospaceSourceConfiguration?.yospaceAssetType == .linear {
            if event.metadataType == .ID3 {
                trackId3(event)
            } else if event.metadataType == .daterange {
                dateRangeEmitter?.trackEmsg(event)
            }
        }
        for listener: PlayerListener in listeners {
            listener.onMetadata?(event)
        }
    }

    func trackId3(_ event: MetadataEvent) {
        let meta = YSTimedMetadata.createFromMetadata(event: event)
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
            let dictionary = [kYoMetadataKey: meta]
            self.notify(dictionary: dictionary, name: YoTimedMetadataNotification)
        }
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        let dictionary = [kYoPlayheadKey: Int(currentTimeWithAds()), kYoCompletedKey: Int(truncating: true)]
        self.notify(dictionary: dictionary, name: YoPlaybackEndedNotification)

        for listener: PlayerListener in listeners {
            listener.onPlaybackFinished?(event)
        }
    }

    func notify(dictionary: [String: Any], name: String) {
        BitLog.d("YoSpace sending \(name)")
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
        receivedFirstPlayhead = true
        
        if liveAdPaused {
            if let adBreak = activeAdBreak, let advert = activeAd {
                // Send skip event if live window has moved beyond paused ad
                if event.currentTime > adBreak.absoluteEnd {
                    onAdSkipped(AdSkippedEvent(ad: advert))
                }
            }
            liveAdPaused = false
        }
        
        // Send to the normalizer so the date emitter can use the normalized value
        // Future use could propagate to the event as well, for media time
        let _ = playheadNormalizer?.normalize(time: self.currentTimeWithAds())
        
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

    public func onAdQuartile(_ event: AdQuartileEvent) {
        BitLog.d("onAdQuartile: ")
        for listener: PlayerListener in listeners {
            listener.onAdQuartile?(event)
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

    public func onDrmDataParsed(_ event: DrmDataParsedEvent) {
        for listener: PlayerListener in listeners {
            listener.onDrmDataParsed?(event)
        }
    }
}

// MARK: AdBreak Transformation

extension YSAdBreak {
    func toYospaceAdBreak(absoluteStart: Double, relativeStart: Double) -> YospaceAdBreak {
        let yospaceAdBreak = YospaceAdBreak(
            identifier: adBreakIdentifier(),
            absoluteStart: absoluteStart,
            absoluteEnd: absoluteStart + adBreakDuration(),
            duration: adBreakDuration(),
            relativeStart: relativeStart,
            scheduleTime: 0,
            replaceContentDuration: 0,
            position: adBreakPosition().toYospaceAdBreakPosition()
        )

        // Add adverts to ad break
        var adAbsoluteStart = absoluteStart
        for case let advert as YSAdvert in adverts() {
            yospaceAdBreak.register(advert.toYospaceAd(absoluteStart: adAbsoluteStart, relativeStart: relativeStart))
            adAbsoluteStart += advert.advertDuration()
        }

        return yospaceAdBreak
    }
}

extension YSEAdBreakPosition {
    func toYospaceAdBreakPosition() -> YospaceAdBreakPosition {
        switch self {
        case .prerollPosition:
            return .preroll
        case .midrollPosition:
            return .midroll
        case .postrollPosition:
            return .postroll
        case .unknownPosition, _:
            return .unknown
        }
    }
}

// MARK: - Ad Transformation

extension YSAdvert {
    func toYospaceAd(absoluteStart: Double, relativeStart: Double) -> YospaceAd {
        return YospaceAd(
            identifier: advertIdentifier(),
            creativeId: linearCreativeElement().linearIdentifier(),
            sequence: advertProperty("sequence"),
            absoluteStart: absoluteStart,
            relativeStart: relativeStart,
            duration: advertDuration(),
            absoluteEnd: absoluteStart + advertDuration(),
            system: advertProperty("AdSystem"),
            title: advertProperty("AdTitle"),
            advertiser: advertProperty("Advertiser"),
            hasInteractiveUnit: hasLinearInteractiveUnit(),
            lineage: advertLineage(),
            extensions:
            // advertExtensions() returns the "extensions" node itself
            // This creates a list of child "extension" nodes to be consistent with Android
            advertExtensions()?.children().compactMap { $0 as? YSXmlNode } ?? [YSXmlNode](),
            isFiller: isFiller(),
            isLinear: !hasLinearInteractiveUnit(),
            clickThroughUrl: linearCreativeElement().linearClickthroughURL(),
            mediaFileUrl: linearCreativeElement().interactiveUnit()?.unitSource()
        )
    }
}
