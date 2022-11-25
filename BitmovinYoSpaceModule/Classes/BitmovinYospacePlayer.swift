import UIKit
import BitmovinPlayer
import YOAdManagement

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

open class BitmovinYospacePlayer : NSObject {
    // MARK: - Bitmovin Yospace Player attributes
    var yospacesession: YOSession?
    var sessionStatus: SessionStatus = .notInitialised
    var yospaceSourceConfiguration: YospaceSourceConfiguration?
    var yospaceConfiguration: YospaceConfiguration?
    var integrationConfiguration: IntegrationConfiguration?
    var sourceConfiguration: SourceConfig?
    var listeners: [PlayerListener] = []
    var yospacePlayerPolicy: YospacePlayerPolicy?
    var yospaceListeners: [YospaceListener] = []
    public private(set) var timeline: AdTimeline?
    var realAdBreaks: [YOAdBreak] = []
    var truexConfiguration: TruexConfiguration?
    var dateRangeEmitter: DateRangeEmitter?
    var playheadNormalizer: PlayheadNormalizer?
    var receivedFirstPlayhead: Bool = false
    var integrationListeners: [IntegrationListener] = []
    var activeAdBreak: YospaceAdBreak?
    var activeAd: YospaceAd?
    var liveAdPaused = false
    public var player: Player!

    #if os(iOS)
    private var truexRenderer: BitmovinTruexRenderer?
    #endif

    var adBreaks: [YOAdBreak] {
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
        get {
            return self.yospacePlayerPolicy?.playerPolicy
        }
        set (playerPolicy) {
            self.yospacePlayerPolicy?.playerPolicy = playerPolicy
        }
    }

    public func duration() -> TimeInterval {
        return player.duration - self.adBreaks.reduce(0) {$0 + $1.duration}
    }

    public func currentTime() -> TimeInterval {
        if isAd() {
            // Return ad time
            return player.currentTime - (activeAd?.absoluteStart ?? 0.0)
        } else if isLive() {
            // Return absolute time
            return player.currentTime
        } else /* VOD */ {
            // Return relative time; fallback to absolute time
            return timeline?.absoluteToRelative(time: player.currentTime) ?? player.currentTime
        }
    }

    public var suppressAnalytics: Bool = false {
        didSet {
            yospacesession?.suppressAnalytics(suppressAnalytics)
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
    public init(configuration: PlayerConfig, yospaceConfiguration: YospaceConfiguration? = nil, integrationConfiguration: IntegrationConfiguration? = nil) {
        super.init()
        self.yospaceConfiguration = yospaceConfiguration
        self.integrationConfiguration = integrationConfiguration
        player = PlayerFactory.create(playerConfig: configuration)
        sessionStatus = .notInitialised
        player.add(listener: self) // TODO: add listener

        BitLog.isEnabled = yospaceConfiguration?.isDebugEnabled ?? false
        self.yospacePlayerPolicy = YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))

        // For the immediate, only utilizing the normalizer inside the DateEmitter, as that solves the most pressing problems
        // We can potentially expand to normalizing all time values post-validation
        // Note - we may need to initialize the normalizer before adding listeners here, to give event handler precedence to the normalizer
        if let integrationConfiguration = self.integrationConfiguration {
            // Using playhead normalization is opt-in
            if integrationConfiguration.enablePlayheadNormalization {
                self.playheadNormalizer = PlayheadNormalizer(player: self, eventDelegate: self)
            }
        }
        self.dateRangeEmitter = DateRangeEmitter(player: self, normalizer: playheadNormalizer)
    }

    public func destroy() {
        resetYospaceSession()
        integrationListeners.removeAll()
        yospaceListeners.removeAll()
        listeners.removeAll()
        player.destroy()
    }

    // MARK: loading a yospace source

    /**
     Loads a new yospace source into the player
     
     **!! The BitmovinYospacePlayer will only be able to play Yospace streams. It will error out on all other streams. Please add a YospaceListener to be notified of these errors !!**
     
     - Parameters:
     - sourceConfiguration: SourceConfiguration of your Yospace HLSSource
     - yospaceConfiguration: YospaceConfiguration to be used during this session playback. You must identify the source as .linear .vod or .startOver
     */
    open func load(sourceConfiguration: SourceConfig, yospaceSourceConfiguration: YospaceSourceConfiguration? = nil, truexConfiguration: TruexConfiguration? = nil) {
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
        let url = sourceConfiguration.url
        logMessage.append("Source=\(url.absoluteString)")
        
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

        let yospaceProperties = YOSessionProperties()
        yospacesession?.suppressAnalytics(true)

        if let timeout = yospaceConfiguration?.timeout {
            yospaceProperties.timeout = timeout
        }

        if let pollingInterval = yospaceConfiguration?.pollingInterval {
            yospaceProperties.resourceTimeout = TimeInterval(pollingInterval)
        }

        if let userAgent = yospaceConfiguration?.userAgent {
            yospaceProperties.userAgent = userAgent
        }

        if yospaceConfiguration?.isDebugEnabled == true {
            YOSessionProperties.setDebugFlags(YODebugFlags.DEBUG_ALL)
        }

        if self.sourceConfiguration?.type != .hls {
            onError(SourceErrorEvent(code: .general, message: "Invalid source provided. Yospace URL must be HLS", data: nil))
            return
        }

        guard let yospaceSourceConfiguration = yospaceSourceConfiguration else {
            BitLog.d("NO yospaceSourceConfiguration")
            player.load(sourceConfig: sourceConfiguration)
            return
        }

        switch yospaceSourceConfiguration.yospaceAssetType {
        case .linear:
            loadLive(url: url, yospaceProperties: yospaceProperties)
        case .vod:
            loadVOD(url: url, yospaceProperties: yospaceProperties)
        }
    }

    public func unload() {
        BitLog.d("Unload: ")
        player.unload()
    }

    // MARK: - playback methods
    public func pause() {
        if let session = self.yospacesession {
            if !session.canPause() {
                return
            }
        }
        player.pause()
    }

    public func seek(time: TimeInterval) {
        if let session = self.yospacesession {
            let seekTime = session.willSeek(to: time)
            let absoluteSeekTime = timeline?.relativeToAbsolute(time: seekTime) ?? seekTime
            BitLog.d("Seeking: Original: \(time) Manager: \(seekTime) Absolute \(absoluteSeekTime)")
            player.seek(time: absoluteSeekTime)
        } else {
            BitLog.d("Seeking to: \(time)")
            player.seek(time: time)
        }
    }

    public func forceSeek(time: TimeInterval) {
        BitLog.d("Seeking to: \(time)")
        player.seek(time: time)
    }

    // MARK: - event handling
    public func add(listener: PlayerListener) {
        listeners.append(listener)
    }

    public func remove(listener: PlayerListener) {
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

    func resetYospaceSession() {
        self.yospacesession?.shutdown()
        self.yospacesession = nil
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

    func loadVOD(url: URL, yospaceProperties: YOSessionProperties) {
        YOSessionVOD.create(url.absoluteString, properties: yospaceProperties, completionHandler: sessionDidInitialise)
    }

    func loadLive(url: URL, yospaceProperties: YOSessionProperties) {
        YOSessionLive.create(url.absoluteString, properties: yospaceProperties, completionHandler: sessionDidInitialise)
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

    public func skipAd() {
        if sessionStatus != .notInitialised {
            guard yospacesession != nil else {
                return
            }

            let adBreak: YospaceAdBreak? = getActiveAdBreak()
            if let currentBreak = adBreak {
                player.seek(time: currentBreak.absoluteEnd)
            }
        } else {
            player.skipAd()
        }
    }

    public func isAd() -> Bool {
        if sessionStatus != .notInitialised {
            return activeAd != nil
        } else {
            return player.isAd
        }
    }
    
    public func isLive() -> Bool {
        return player.isLive
    }

    public func currentTimeWithAds() -> TimeInterval {
        return player.currentTime
    }

    public func durationWithAds() -> TimeInterval {
        return player.duration
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
        yospacesession?.suppressAnalytics(false)

        // Seek to end of TrueX ad filler
        if let advert = activeAd {
            BitLog.d("Skipping TrueX filler")
            forceSeek(time: advert.absoluteEnd)
        }

        BitLog.d("Resuming player")
        player.play()
    }

    func skipAdBreak() {
        BitLog.d("YoSpace analytics unsuppressed")
        yospacesession?.suppressAnalytics(false)

        // Seek to end of ad break
        if let adBreak = activeAdBreak {
            BitLog.d("Skipping ad break")
            // Add increment of 0.25 to make sure we land back in main content
            forceSeek(time: adBreak.absoluteEnd + 0.25)
        }

        BitLog.d("Resuming player")
        player.play()
    }

    func sessionAdFree() {
        BitLog.d("Session ad free")
        for listener in yospaceListeners {
            listener.onTrueXAdFree()
        }
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer {
    public func addYospaceAnalyticEventListener() {
        BitLog.d("Register callbacks for analytic events")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertBreakDidStart),
                                               name: NSNotification.Name.YOAdvertBreakStart,
                                               object: self.yospacesession)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertDidStart),
                                               name: NSNotification.Name.YOAdvertStart,
                                               object: self.yospacesession)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertDidEnd),
                                               name: NSNotification.Name.YOAdvertEnd,
                                               object: self.yospacesession)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertBreakDidEnd),
                                               name: NSNotification.Name.YOAdvertBreakEnd,
                                               object: self.yospacesession)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackingEventDidOccur),
                                               name: NSNotification.Name.YOTrackingEvent,
                                               object: self.yospacesession)
        
        
    }
    
    
    @objc public func advertBreakDidStart(notification: NSNotification) {
        BitLog.d("YoSpace advertBreakDidStart: \(notification)")
        if let dict = notification.userInfo as NSDictionary? {
            if let adBreak = dict[YOAdBreakKey] as? YOAdBreak, !isLive() {
                handleAdBreakEvent(adBreak)
            }
        }
    }
    
    @objc public func advertDidStart(notification: NSNotification) -> [Any]? {
        BitLog.d("YoSpace advertDidStart: \(notification)")
        
        if isLive(), activeAdBreak == nil, let currentAdBreak = yospacesession?.currentAdBreak() {
            handleAdBreakEvent(currentAdBreak)
        }
        
        var advert: YOAdvert? = nil
        if let dict = notification.userInfo as NSDictionary? {
            if let YOAd = dict[YOAdvertKey] as? YOAdvert {
                let ad = createActiveAd(advert: YOAd)
                activeAd = ad
                advert = YOAd
            }
        }
        guard let yospaceAd = advert else { return [] }
        guard let bitmovinAd = activeAd else { return [] }
        
        #if os(iOS)
        if let renderer = truexRenderer {
            BitLog.d("TrueX ad found: \(yospaceAd)")

            // Suppress analytics in order for YoSpace TrueX tracking to work
            BitLog.d("YoSpace analytics suppressed")
            yospacesession?.suppressAnalytics(true)
            BitLog.d("Pausing player")
            player.pause()

            let adBreakPosition: YospaceAdBreakPosition = activeAdBreak?.relativeStart == 0 ? .preroll : .midroll
            renderer.renderTruexAd(advert: yospaceAd, adBreakPosition: adBreakPosition)
        }
        #endif

        let staticCompanionAds = (yospaceAd.companionAds(YOResourceType.YOStaticResource) as? [YOCompanionCreative])?
            .map { (creative: YOCompanionCreative) -> CompanionAd in
                let resource = creative.resource(of: YOResourceType.YOStaticResource)
                let url = resource?.stringData

                return CompanionAd(
                    id: creative.creativeIdentifier,
                    adSlotId: creative.advertIdentifier,
                    width:  CGFloat(Double(creative.property("width")?.value ?? "0.0")!),
                    height: CGFloat(Double(creative.property("height")?.value ?? "0.0")!),
                    clickThroughUrl: creative.clickthroughUrl(),
                    resource: CompanionAdResource(source: url, type: CompanionAdType.static)
                )
            } ?? []
        
        let htmlCompanionAds = (yospaceAd.companionAds(YOResourceType.YOHTMLResource) as? [YOCompanionCreative])?
            .map { (creative: YOCompanionCreative) -> CompanionAd in
                let resource = creative.resource(of: YOResourceType.YOHTMLResource)
                let html = resource?.stringData
                
                return CompanionAd(
                    id: creative.creativeIdentifier,
                    adSlotId: creative.advertIdentifier,
                    width:  CGFloat(Double(creative.property("width")?.value ?? "0.0")!),
                    height: CGFloat(Double(creative.property("height")?.value ?? "0.0")!),
                    clickThroughUrl: creative.clickthroughUrl(),
                    resource: CompanionAdResource(source: html, type: CompanionAdType.html)
                )
            } ?? []
        
        let companionAds = [staticCompanionAds, htmlCompanionAds].flatMap { $0 }

        let adStartedEvent = YospaceAdStartedEvent(
            clickThroughUrl: bitmovinAd.clickThroughUrl,
            duration: yospaceAd.duration,
            timeOffset: yospaceAd.start,
            ad: bitmovinAd,
            companionAds: companionAds
        )

        BitLog.d("Emitting AdStartedEvent")
        for listener: PlayerListener in listeners {
            listener.onAdStarted?(adStartedEvent, player: player)
        }

        return []
    }

    @objc public func advertDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertDidEnd")

        if let dict = notification.userInfo as NSDictionary? {
            if let YOAd = dict[YOAdvertKey] as? YOAdvert {
                let ad = createActiveAd(advert: YOAd)
                
                BitLog.d("Emitting AdFinishedEvent")
                for listener: PlayerListener in listeners {
                    listener.onAdFinished?(AdFinishedEvent(ad: ad), player: player)
                }
            }
        }

        activeAd = nil
    }

    @objc public func advertBreakDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertBreakDidEnd")

        if let dict = notification.userInfo as NSDictionary? {
            if let YOAdBreak = dict[YOAdBreakKey] as? YOAdBreak, !isLive() {
                let adBreak = createActiveAdBreak(adBreak: YOAdBreak)
                
                BitLog.d("Emitting AdBreakFinishedEvent")
                for listener: PlayerListener in listeners {
                    listener.onAdBreakFinished?(AdBreakFinishedEvent(adBreak: adBreak), player: player)
                }
            }
        }

        activeAdBreak = nil
    }

    @objc public func trackingEventDidOccur(notification: NSNotification) {
        BitLog.d("YoSpace trackingEventDidOccur: \(notification)")

        if let dict = notification.userInfo as NSDictionary? {
            if let event = dict[YOEventNameKey] as? String {
                switch event {
//                case "firstQuartile":
//                    onAdQuartile(AdQuartileEvent(quartile: .firstQuartile))
//                case "midpoint":
//                    onAdQuartile(AdQuartileEvent(quartile: .midpoint))
//                case "thirdQuartile":
//                    onAdQuartile(AdQuartileEvent(quartile: .thirdQuartile))
                default:
                    BitLog.d("Skip event: \(event)")
                }
            }
        }
    }

    public func timelineUpdateReceived(_ vmap: String) {
        if let timeline = self.yospacesession?.adBreaks(YOAdBreakType.linearType) as? [YOAdBreak] {
            BitLog.d("YoSpace timelineUpdateReceived: \(timeline.count)")
            self.adBreaks = timeline
        }
    }

    private func createActiveAd(advert: YOAdvert) -> YospaceAd {
        if let adBreakAd = (activeAdBreak?.ads
                .compactMap { $0 as? YospaceAd }
                .first { $0.identifier == advert.identifier }) {
            return adBreakAd
        } else {
            let absoluteTime = player.currentTime
            var adAbsoluteStart: Double
            var adRelativeStart: Double

            if isLive() {
                adAbsoluteStart = absoluteTime
                adRelativeStart = activeAdBreak?.relativeStart ?? adAbsoluteStart
            } else /* VOD */ {
                adAbsoluteStart = advert.start
                adRelativeStart = timeline?.absoluteToRelative(time: adAbsoluteStart) ?? adAbsoluteStart
            }

            return advert.toYospaceAd(absoluteStart: adAbsoluteStart, relativeStart: adRelativeStart)
        }
    }

    private func createActiveAdBreak(adBreak: YOAdBreak) -> YospaceAdBreak {
        let absoluteTime = player.currentTime
        var adBreakAbsoluteStart: Double
        var adBreakRelativeStart: Double

        if isLive() {
            adBreakAbsoluteStart = absoluteTime
            adBreakRelativeStart = absoluteTime
        } else /* VOD */ {
            adBreakAbsoluteStart = adBreak.start
            adBreakRelativeStart = timeline?.absoluteToRelative(time: adBreakAbsoluteStart) ?? adBreakAbsoluteStart
        }

        return adBreak.toYospaceAdBreak(absoluteStart: adBreakAbsoluteStart, relativeStart: adBreakRelativeStart)
    }

    private func handleAdBreakEvent(_ adBreak: YOAdBreak) {
        activeAdBreak = createActiveAdBreak(adBreak: adBreak)

        BitLog.d("Emitting AdBreakStartedEvent: position=\(adBreak.position)")
        let adBreakStartEvent = AdBreakStartedEvent(adBreak: activeAdBreak!)
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(adBreakStartEvent, player: player)
        }
    }
}

// MARK: - YSAnalyticsObserver
extension BitmovinYospacePlayer {
    public func sessionDidInitialise(with stream: YOSession) {
        BitLog.d("Session Did Initialise")

        if let timeline = stream.adBreaks(YOAdBreakType.linearType) as? [YOAdBreak] {
            BitLog.d("Initial Ad Breaks Received: \(timeline.count)")
            self.adBreaks = timeline
        }

        // set the policy handler
        let policy = self.yospacePlayerPolicy ?? YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
        stream.setPlaybackPolicyHandler(policy)
        
        switch stream.sessionResult {
        case .notInitialised:
            BitLog.e("Not initialized url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                onError(SourceErrorEvent(code: .general, message: "Yospace not initialized", data: nil))
//                self.onWarning(WarningEvent(code: YospaceErrorCode.notIntialised.rawValue, message: "Not initialized"))
                player.load(sourceConfig: sourceConfiguration)
            } else {
                onError(SourceErrorEvent(code: .general, message: "Yospace not initialized", data: nil))
//                onError(ErrorEvent(code: YospaceErrorCode.notIntialised.rawValue, message: "Not Intialized"))
            }
        case .noAnalytics:
            // store the session
            self.yospacesession = stream
            
            BitLog.d("No Analytics url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                onError(SourceErrorEvent(code: .general, message: "No analytics", data: nil))
//                self.onWarning(WarningEvent(code: YospaceErrorCode.noAnalytics.rawValue, message: "No analytics"))
                player.load(sourceConfig: sourceConfiguration)
            } else {
                onError(SourceErrorEvent(code: .general, message: "No analytics", data: nil))
//                onError(ErrorEvent(code: YospaceErrorCode.noAnalytics.rawValue, message: "No Analytics"))
            }
        case .initialised:
            // store the session
            self.yospacesession = stream
            // start observing analytic events
            addYospaceAnalyticEventListener()
            
            BitLog.d("With Analytics url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            let sourceConfig = SourceConfig(url: URL(string: stream.playbackUrl!)!, type: .hls)
            if let drmConfiguration: DrmConfig = self.sourceConfiguration?.drmConfig {
                sourceConfig.drmConfig = drmConfiguration
            }
            player.load(sourceConfig: sourceConfig)
        default:
            break
        }
    }

    public func operationDidFailWithError(_ error: Error) {
        if let sourceConfiguration = self.sourceConfiguration, yospaceSourceConfiguration?.retryExcludingYospace == true {
            BitLog.w("Attempting to playback the stream url without Yospace")
            onError(SourceErrorEvent(code: .general, message: "Unknown Error. Initialize failed with Error", data: nil))
//            self.onWarning(WarningEvent(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error"))
            player.load(sourceConfig: sourceConfiguration)
        } else {
            onError(SourceErrorEvent(code: .general, message: "Unknown Error. Initialize failed with Error", data: nil))
//            onError(ErrorEvent(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error"))
        }
    }

}

// MARK: - PlayerListener
extension BitmovinYospacePlayer: PlayerListener {

    public func onEvent(_ event: PlayerEvent, player: Player) {
        BitLog.d("onPlayer: \(event)")

        for listener: PlayerListener in listeners {
            listener.onPlay?(PlayEvent(time: currentTime()), player: player)
        }
    }

    public func onEvent(_ event: PlayingEvent, player: Player) {
        BitLog.d("onPlaying: \(event)")
        
        if sessionStatus == .notInitialised || sessionStatus == .ready {
            sessionStatus = .playing
            self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStartEvent, playhead: currentTimeWithAds())
        } else {
            self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackResumeEvent, playhead: currentTimeWithAds())
        }
        for listener: PlayerListener in listeners {
            listener.onPlaying?(PlayingEvent(time: currentTime()), player: player)
        }
    }

    public func onEvent(_ event: PausedEvent, player: Player) {
        BitLog.d("onPaused: \(event)")

        liveAdPaused = isLive() && isAd()
        self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackPauseEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onPaused?(PausedEvent(time: currentTime()), player: player)
        }
    }

    public func onEvent(_ event: SourceUnloadedEvent, player: Player) {
        if sessionStatus != .notInitialised {
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetYospaceSession()
        }
        for listener: PlayerListener in listeners {
            listener.onSourceUnloaded?(event, player: player)
        }
    }

    public func onEvent(_ event: StallStartedEvent, player: Player) {
        self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStallEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onStallStarted?(event, player: player)
        }
    }

    public func onEvent(_ event: StallEndedEvent, player: Player) {
        self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackContinueEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onStallEnded?(event, player: player)
        }
    }
//
    public func onError(_ event: Event) {
//        for listener: PlayerListener in listeners {
//            listener.onError?(event, player: player)
//        }
    }
//
//    public func onWarning(_ event: WarningEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onWarning?(event, player: player)
//        }
//    }

    public func onEvent(_ event: ReadyEvent, player: Player) {
        BitLog.d("onReady: \(event)")

        if sessionStatus == .notInitialised {
            sessionStatus = .ready
        }
        for listener: PlayerListener in listeners {
            listener.onReady?(event, player: player)
        }
    }
//
//    public func onMuted(_ event: MutedEvent) {
//        self.yospacesession?.volumeDidChange(self.isMuted)
//        for listener: PlayerListener in listeners {
//            listener.onMuted?(event, player: player)
//        }
//    }
//
//    public func onUnmuted(_ event: UnmutedEvent) {
//        self.yospacesession?.volumeDidChange(self.isMuted)
//        for listener: PlayerListener in listeners {
//            listener.onUnmuted?(event, player: player)
//        }
//    }
//
//    public func onMetadataParsed(_ event: MetadataParsedEvent) {
//        // Note - this is a workaround for the intermittent missing iOS metadata issue,
//        // where on start of the stream, date range metadata is not always being propagated to onMetadata
//        // It is surfaced as parsed metadata, so we'll check here if it's the correct type and time, and if so,
//        // parse it and track it as an ID3
//        //
//        // If onMetadata does fire afterwards, it will be ignored by handling in DateRangeEmitter
//        if receivedFirstPlayhead == false {
//            if yospaceSourceConfiguration?.yospaceAssetType == .linear {
//                if let dateRangeMetadata = event.metadata as? DaterangeMetadata {
//                    let metadataTime = String(format: "%.2f", dateRangeMetadata.startDate.timeIntervalSince1970)
//                    let currentTime = String(format: "%.2f", self.currentTimeWithAds())
//                    if metadataTime == currentTime {
//                        BitLog.d("onMetadataParsed: tracking initial emsg")
//                        dateRangeEmitter?.trackEmsg(event)
//                    }
//                }
//            }
//        }
//
//        for listener: PlayerListener in listeners {
//            listener.onMetadataParsed?(event, player: player)
//        }
//    }
//
//    public func onMetadata(_ event: MetadataEvent) {
//        BitLog.d("onMetadata: \(event)")
//
//        if yospaceSourceConfiguration?.yospaceAssetType == .linear {
//            if event.metadataType == .ID3 {
//                trackId3(event)
//            } else if event.metadataType == .daterange {
//                dateRangeEmitter?.trackEmsg(event)
//            }
//        }
//        for listener: PlayerListener in listeners {
//            listener.onMetadata?(event, player: player)
//        }
//    }
//
//    func trackId3(_ event: MetadataEvent) {
//        guard let meta = YOTimedMetadata.createFromMetadata(event: event) else { return }
//        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
//            self.yospacesession?.timedMetadataWasCollected(meta)
//        }
//    }
//
//    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
//        self.yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStopEvent, playhead: currentTimeWithAds())
//
//        for listener: PlayerListener in listeners {
//            listener.onPlaybackFinished?(event, player: player)
//        }
//    }
//
//    public func onDurationChanged(_ event: DurationChangedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onDurationChanged?(DurationChangedEvent(duration: duration()), player: player)
//        }
//    }
//
//    public func onTimeChanged(_ event: TimeChangedEvent) {
//        receivedFirstPlayhead = true
//
//        if liveAdPaused {
//            if let adBreak = activeAdBreak, let advert = activeAd {
//                // Send skip event if live window has moved beyond paused ad
//                if event.currentTime > adBreak.absoluteEnd {
//                    onAdSkipped(AdSkippedEvent(ad: advert))
//                }
//            }
//            liveAdPaused = false
//        }
//
//        // Send to the normalizer so the date emitter can use the normalized value
//        // Future use could propagate to the event as well, for media time
//        _ = playheadNormalizer?.normalize(time: self.currentTimeWithAds())
//
//        for listener: PlayerListener in listeners {
//            listener.onTimeChanged?(TimeChangedEvent(currentTime: currentTime()), player: player)
//        }
//    }
//
//    public func onSeek(_ event: SeekEvent) {
//        for listener: PlayerListener in listeners {
//            let position = timeline?.absoluteToRelative(time: event.position) ?? event.position
//            let seekTarget = timeline?.absoluteToRelative(time: event.seekTarget) ?? event.seekTarget
//            listener.onSeek?(SeekEvent(position: position, seekTarget: seekTarget))
//        }
//    }
//
//    /**
//     Unmodified eevents, passing thought to registered listeners
//     */
//    public func onSeeked(_ event: SeekedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSeeked?(event)
//        }
//    }
//
//    public func onDestroy(_ event: DestroyEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onDestroy?(event)
//        }
//    }
//
//    public func onEvent(_ event: PlayerEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onEvent?(event)
//        }
//    }
//
//    public func onAdClicked(_ event: AdClickedEvent) {
//        BitLog.d("onAdClicked: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdClicked?(event)
//        }
//    }
//
//    public func onAdSkipped(_ event: AdSkippedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onAdSkipped?(event)
//        }
//    }
//
//    public func onAdStarted(_ event: AdStartedEvent) {
//        BitLog.d("onAdStarted: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdStarted?(event)
//        }
//    }
//
//    public func onAdQuartile(_ event: AdQuartileEvent) {
//        BitLog.d("onAdQuartile: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdQuartile?(event)
//        }
//    }
//
//    public func onCastStart(_ event: CastStartEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastStart?(event)
//        }
//    }
//
//    public func onAdFinished(_ event: AdFinishedEvent) {
//        BitLog.d("onAdFinished: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdFinished?(event)
//        }
//    }
//
//    public func onTimeShift(_ event: TimeShiftEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onTimeShift?(event)
//        }
//    }
//
//    public func onAdScheduled(_ event: AdScheduledEvent) {
//        BitLog.d("onAdScheduled: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdScheduled?(event)
//        }
//    }
//
//    public func onAudioAdded(_ event: AudioAddedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onAudioAdded?(event)
//        }
//    }
//
//    public func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onVideoDownloadQualityChanged?(event)
//        }
//    }
//
//    public func onCastPlaying(_ event: CastPlayingEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastPlaying?(event)
//        }
//    }
//
//    public func onCastStarted(_ event: CastStartedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastStarted?(event)
//        }
//    }
//
//    public func onCastStopped(_ event: CastStoppedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastStopped?(event)
//        }
//    }
//
//    public func onCastAvailable(_ event: CastAvailableEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastAvailable?(event)
//        }
//    }
//
//    public func onCastPlaybackFinished(_ event: CastPlaybackFinishedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastPlaybackFinished?(event)
//        }
//    }
//
//    public func onCastPaused(_ event: CastPausedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastPaused?(event)
//        }
//    }
//
//    public func onTimeShifted(_ event: TimeShiftedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onTimeShifted?(event)
//        }
//    }
//
//    public func onAudioChanged(_ event: AudioChangedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onAudioChanged?(event)
//        }
//    }
//
//    public func onAudioRemoved(_ event: AudioRemovedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onAudioRemoved?(event)
//        }
//    }
//
//    public func onSourceLoaded(_ event: SourceLoadedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSourceLoaded?(event)
//        }
//    }
//
//    public func onSubtitleAdded(_ event: SubtitleAddedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSubtitleAdded?(event)
//        }
//    }
//
//    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
//        BitLog.d("onAdBreakStarted: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdBreakStarted?(event)
//        }
//    }
//
//    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
//        BitLog.d("onAdBreakFinished: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdBreakFinished?(event)
//        }
//    }
//
//    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent) {
//        BitLog.d("onAdManifestLoaded: ")
//        for listener: PlayerListener in listeners {
//            listener.onAdManifestLoaded?(event)
//        }
//    }
//
//    public func onCastTimeUpdated(_ event: CastTimeUpdatedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCastTimeUpdated?(event)
//        }
//    }
//
//    public func onSubtitleRemoved(_ event: SubtitleRemovedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSubtitleRemoved?(event)
//        }
//    }
//
//    public func onSubtitleChanged(_ event: SubtitleChangedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSubtitleChanged?(event)
//        }
//    }
//
//    public func onCueEnter(_ event: CueEnterEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCueEnter?(event)
//        }
//    }
//
//    public func onCueExit(_ event: CueExitEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onCueExit?(event)
//        }
//    }
//
//    public func onDvrWindowExceeded(_ event: DvrWindowExceededEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onDvrWindowExceeded?(event)
//        }
//    }
//
//    public func onDownloadFinished(_ event: DownloadFinishedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onDownloadFinished?(event)
//        }
//    }
//
//    public func onRenderFirstFrame(_ event: RenderFirstFrameEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onRenderFirstFrame?(event)
//        }
//    }
//
//    public func onSourceWillUnload(_ event: SourceWillUnloadEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onSourceWillUnload?(event)
//        }
//    }
//
//    public func onVideoSizeChanged(_ event: VideoSizeChangedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onVideoSizeChanged?(event)
//        }
//    }
//
//    public func onConfigurationUpdated(_ event: ConfigurationUpdatedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onConfigurationUpdated?(event)
//        }
//    }
//
//    public func onDrmDataParsed(_ event: DrmDataParsedEvent) {
//        for listener: PlayerListener in listeners {
//            listener.onDrmDataParsed?(event)
//        }
//    }
}

// MARK: AdBreak Transformation

extension YOAdBreak {
    func toYospaceAdBreak(absoluteStart: Double, relativeStart: Double) -> YospaceAdBreak {
        let yospaceAdBreak = YospaceAdBreak(
            identifier: identifier ?? "",
            absoluteStart: absoluteStart,
            absoluteEnd: absoluteStart + duration,
            duration: duration,
            relativeStart: relativeStart,
            scheduleTime: 0,
            replaceContentDuration: 0,
            position: position.toYospaceAdBreakPosition()
        )

        // Add adverts to ad break
        var adAbsoluteStart = absoluteStart
        for case let advert as YOAdvert in adverts {
            yospaceAdBreak.register(advert.toYospaceAd(absoluteStart: adAbsoluteStart, relativeStart: relativeStart))
            adAbsoluteStart += advert.duration
        }

        return yospaceAdBreak
    }
}

extension String {
    func toYospaceAdBreakPosition() -> YospaceAdBreakPosition {
        switch self {
        case "preroll":
            return .preroll
        case "midroll":
            return .midroll
        case "postroll":
            return .postroll
        case "unknown", _:
            return .unknown
        }
    }
}

// MARK: - Ad Transformation

extension YOAdvert {
    func toYospaceAd(absoluteStart: Double, relativeStart: Double) -> YospaceAd {
        return YospaceAd(
            identifier: identifier,
            creativeId: linearCreative.creativeIdentifier,
            sequence:"sequence",
            absoluteStart: absoluteStart,
            relativeStart: relativeStart,
            duration: duration,
            absoluteEnd: absoluteStart + duration,
            system: "AdSystem",
            title: "AdTitle",
            advertiser: "Advertiser",
            hasInteractiveUnit: interactiveCreative != nil,
            lineage: lineage,
            extensions:
            // advertExtensions() returns the "extensions" node itself
            // This creates a list of child "extension" nodes to be consistent with Android
            extensions?.childNodes()?.compactMap { $0 as? YOXmlNode } ?? [YOXmlNode](),
            isFiller: isFiller,
            isLinear: interactiveCreative == nil,
            clickThroughUrl: URL(string: linearCreative.clickthroughUrl() ?? ""),
            mediaFileUrl: URL(string: interactiveCreative?.source ?? "")
        )
    }
}
