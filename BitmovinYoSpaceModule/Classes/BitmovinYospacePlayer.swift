import BitmovinPlayer
import UIKit
import YOAdManagement

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

public class BitmovinYospacePlayer: NSObject, Player {
    // MARK: - Bitmovin Player properties

    public var isDestroyed: Bool { return player.isDestroyed }

    public var isMuted: Bool { return player.isMuted }

    public var volume: Int {
        get { return player.volume }
        set { player.volume = newValue }
    }

    public var isPaused: Bool { return player.isPaused }

    public var isPlaying: Bool { return player.isPlaying }

    public var isLive: Bool { return player.isLive }

    public var duration: TimeInterval { player.duration - adBreaks.reduce(0) { $0 + $1.duration } }

    public var currentTime: TimeInterval {
        if isAd {
            // Return ad time
            return player.currentTime - (activeAd?.absoluteStart ?? 0.0)
        } else if isLive {
            // Return absolute time
            return player.currentTime
        } else /* VOD */ {
            // Return relative time; fallback to absolute time
            return timeline?.absoluteToRelative(time: player.currentTime) ?? player.currentTime
        }
    }

    public var config: PlayerConfig { return player.config }

    public var source: BitmovinPlayer.Source? { return player.source }

    public var maxTimeShift: TimeInterval { return player.maxTimeShift }

    public var timeShift: TimeInterval {
        get { return player.timeShift }
        set { player.timeShift = newValue }
    }

    public var availableSubtitles: [BitmovinPlayer.SubtitleTrack] { return player.availableSubtitles }

    public var subtitle: BitmovinPlayer.SubtitleTrack { return player.subtitle }

    public var availableAudio: [BitmovinPlayer.AudioTrack] { return player.availableAudio }

    public var audio: BitmovinPlayer.AudioTrack? { return player.audio }

    public var isAd: Bool {
        if sessionStatus != .notInitialised {
            return activeAd != nil
        } else {
            return player.isAd
        }
    }

    public var isAirPlayActive: Bool { return player.isAirPlayActive }

    public var isAirPlayAvailable: Bool { return player.isAirPlayAvailable }

    public var availableVideoQualities: [BitmovinPlayer.VideoQuality] { return player.availableVideoQualities }

    public var videoQuality: BitmovinPlayer.VideoQuality? { return player.videoQuality }

    public var playbackSpeed: Float {
        get { return player.playbackSpeed }
        set { player.playbackSpeed = newValue }
    }

    public var maxSelectableBitrate: UInt {
        get { return player.maxSelectableBitrate }
        set { player.maxSelectableBitrate = newValue }
    }

    public var currentVideoFrameRate: Float { return player.currentVideoFrameRate }

    public var buffer: BufferApi { return player.buffer }

    public var playlist: BitmovinPlayer.PlaylistApi { return player.playlist }

    public var isCasting: Bool { return player.isCasting }

    public var isWaitingForDevice: Bool { return player.isWaitingForDevice }

    public var isCastAvailable: Bool { return player.isCastAvailable }

    public var isOutputObscured: Bool { return player.isOutputObscured }

    @available(iOS 15.0, *)
    public var sharePlay: BitmovinPlayer.SharePlayApi { return player.sharePlay }

    // MARK: - Bitmovin Player methods

    public func load(sourceConfig: SourceConfig) {
        player.load(sourceConfig: sourceConfig)
    }

    public func load(source: BitmovinPlayer.Source) {
        player.load(source: source)
    }

    public func load(playlistConfig: BitmovinPlayer.PlaylistConfig) {
        player.load(playlistConfig: playlistConfig)
    }

    public func play() {
        player.play()
    }

    public func mute() {
        player.mute()
    }

    public func unmute() {
        player.unmute()
    }

    @available(*, deprecated, message: "Use SourceConfig#add(subtitleTrack:) instead.")
    public func addSubtitle(track subtitleTrack: BitmovinPlayer.SubtitleTrack) {
        player.addSubtitle(track: subtitleTrack)
    }

    public func removeSubtitle(trackIdentifier subtitleTrackID: String) {
        player.removeSubtitle(trackIdentifier: subtitleTrackID)
    }

    public func setSubtitle(trackIdentifier subtitleTrackID: String?) {
        player.setSubtitle(trackIdentifier: subtitleTrackID)
    }

    public func setAudio(trackIdentifier audioTrackID: String) {
        player.setAudio(trackIdentifier: audioTrackID)
    }

    public func thumbnail(forTime time: TimeInterval) -> Thumbnail? {
        player.thumbnail(forTime: time)
    }

    public func scheduleAd(adItem: AdItem) {
        player.scheduleAd(adItem: adItem)
    }

    public func showAirPlayTargetPicker() {
        player.showAirPlayTargetPicker()
    }

    public func currentTime(_ timeMode: TimeMode) -> TimeInterval {
        player.currentTime(timeMode)
    }

    public func register(_ playerLayer: AVPlayerLayer) {
        player.register(playerLayer)
    }

    public func unregisterPlayerLayer(_ playerLayer: AVPlayerLayer) {
        player.unregisterPlayerLayer(playerLayer)
    }

    public func register(_ playerViewController: AVPlayerViewController) {
        player.register(playerViewController)
    }

    public func unregisterPlayerViewController(_ playerViewController: AVPlayerViewController) {
        player.unregisterPlayerViewController(playerViewController)
    }

    public func registerAdContainer(_ adContainer: UIView) {
        player.registerAdContainer(adContainer)
    }

    public func setSubtitleStyles(_ subtitleStyles: [AVTextStyleRule]?) {
        player.setSubtitleStyles(subtitleStyles)
    }

    public func canPlay(atPlaybackSpeed playbackSpeed: Float) -> Bool {
        player.canPlay(atPlaybackSpeed: playbackSpeed)
    }

    public func castStop() {
        player.castStop()
    }

    public func castVideo() {
        player.castVideo()
    }

    // MARK: - Yospace properties

    var yospacesession: YOSession?
    var sessionStatus: SessionStatus = .notInitialised
    var yospaceSourceConfig: YospaceSourceConfig?
    var yospaceConfig: YospaceConfig?
    var integrationConfig: IntegrationConfig?
    var sourceConfig: SourceConfig?
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
    var player: Player

    #if os(iOS)
        private var truexRenderer: BitmovinTruexRenderer?
    #endif

    var adBreaks: [YOAdBreak] {
        get {
            return realAdBreaks
        }
        set(adBreaks) {
            realAdBreaks = adBreaks
            timeline = AdTimeline(adBreaks: adBreaks)
            handTimelineUpdated()
        }
    }

    // pass along the BitmovinYospacePlayerPolicy to the internal yospacePlayerPolicy which will be called by by our sessionManager
    public var playerPolicy: BitmovinYospacePlayerPolicy? {
        get {
            return yospacePlayerPolicy?.playerPolicy
        }
        set(playerPolicy) {
            yospacePlayerPolicy?.playerPolicy = playerPolicy
        }
    }

    public var suppressAnalytics: Bool = false {
        didSet(suppressAnalytics) {
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
    public init(playerConfig: PlayerConfig, yospaceConfig: YospaceConfig? = nil, integrationConfig: IntegrationConfig? = nil) {
        player = PlayerFactory.create(playerConfig: playerConfig)
        super.init()
        player.add(listener: self as PlayerListener)

        self.yospaceConfig = yospaceConfig
        self.integrationConfig = integrationConfig
        yospacePlayerPolicy = YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))

        // For the immediate, only utilizing the normalizer inside the DateEmitter, as that solves the most pressing problems
        // We can potentially expand to normalizing all time values post-validation
        // Note - we may need to initialize the normalizer before adding listeners here, to give event handler precedence to the normalizer
        if let integrationConfig = self.integrationConfig {
            // Using playhead normalization is opt-in
            if integrationConfig.enablePlayheadNormalization {
                playheadNormalizer = PlayheadNormalizer(player: self, eventDelegate: self)
            }
        }
        dateRangeEmitter = DateRangeEmitter(player: self, normalizer: playheadNormalizer)
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
    public func load(sourceConfig: SourceConfig, yospaceSourceConfig: YospaceSourceConfig? = nil, truexConfiguration: TruexConfiguration? = nil) {
        #if os(iOS)
            if let truexConfiguration = truexConfiguration {
                self.truexConfiguration = truexConfiguration
                truexRenderer = BitmovinTruexRenderer(configuration: truexConfiguration, eventDelegate: self)
            } else {
                self.truexConfiguration = nil
                truexRenderer = nil
            }
        #endif

        var logMessage = "Load: "
        let url = sourceConfig.url
        logMessage.append("Source=\(url.absoluteString)")

        if let yospaceSourceConfig = yospaceSourceConfig {
            logMessage.append(", YospaceAssetType=\(yospaceSourceConfig.yospaceAssetType.rawValue)")
            logMessage.append(", YospaceRetry=\(yospaceSourceConfig.retryExcludingYospace)")
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
        self.yospaceSourceConfig = yospaceSourceConfig
        self.sourceConfig = sourceConfig

        let yospaceProperties = YOSessionProperties()
        yospacesession?.suppressAnalytics(true)

        if let timeout = yospaceConfig?.timeout {
            yospaceProperties.timeout = timeout
        }

        if let pollingInterval = yospaceConfig?.pollingInterval {
            yospaceProperties.resourceTimeout = TimeInterval(pollingInterval)
        }

        if let userAgent = yospaceConfig?.userAgent {
            yospaceProperties.userAgent = userAgent
        }

        if yospaceConfig?.isDebugEnabled == true {
            YOSessionProperties.setDebugFlags(YODebugFlags.DEBUG_ALL)
        }

        if self.sourceConfig?.type != .hls {
            onError(YospaceErrorEvent(errorCode: .invalidSource, message: "Invalid source provided. Yospace URL must be HLS"), player: self)
            return
        }

        guard let yospaceSourceConfig = yospaceSourceConfig else {
            load(sourceConfig: sourceConfig)
            return
        }

        switch yospaceSourceConfig.yospaceAssetType {
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
        if let session = yospacesession {
            if !session.canPause() {
                return
            }
        }
        player.pause()
    }

    public func seek(time: TimeInterval) {
        if let session = yospacesession {
            let seekTime = session.willSeek(to: time)
            let absoluteSeekTime = timeline?.relativeToAbsolute(time: seekTime) ?? seekTime
            BitLog.d("Seeking: Original: \(time) Manager: \(seekTime) Absolute \(absoluteSeekTime)")
            player.seek(time: absoluteSeekTime)
        } else {
            BitLog.d("Seeking to: \(time)")
            player.seek(time: time)
        }
    }

    func forceSeek(time: TimeInterval) {
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
        yospacesession?.shutdown()
        yospacesession = nil
        adBreaks = []
        activeAd = nil
        activeAdBreak = nil
        liveAdPaused = false
        sessionStatus = .notInitialised
        receivedFirstPlayhead = false
        #if os(iOS)
            truexRenderer?.stopRenderer()
        #endif
    }

    func loadVOD(url: URL, yospaceProperties: YOSessionProperties) {
        YOSessionVOD.create(url.absoluteString, properties: yospaceProperties, completionHandler: sessionDidInitialise)
    }

    func loadLive(url: URL, yospaceProperties: YOSessionProperties) {
        YOSessionLive.create(url.absoluteString, properties: yospaceProperties, completionHandler: sessionDidInitialise)
    }

    func handTimelineUpdated() {
        guard let timeline = timeline else {
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

    public func currentTimeWithAds() -> TimeInterval {
        return player.currentTime
    }

    func durationWithAds() -> TimeInterval {
        return player.duration
    }

    func getActiveAdBreak() -> YospaceAdBreak? {
        return activeAdBreak
    }

    func getActiveAd() -> YospaceAd? {
        return activeAd
    }
}

// MARK: - PlayheadNormalizerEventDelegate

extension BitmovinYospacePlayer: PlayheadNormalizerEventDelegate {
    public func normalizingStarted() {
        for listener in integrationListeners {
            listener.onPlayheadNormalizingStarted()
        }
    }

    public func normalizingFinished() {
        for listener in integrationListeners {
            listener.onPlayheadNormalizingFinished()
        }
    }
}

// MARK: - TruexAdRendererEventDelegate

extension BitmovinYospacePlayer: TruexAdRendererEventDelegate {
    public func skipTruexAd() {
        BitLog.d("YoSpace analytics unsuppressed")
        yospacesession?.suppressAnalytics(false)

        // Seek to end of TrueX ad filler
        if let advert = activeAd {
            BitLog.d("Skipping TrueX filler")
            forceSeek(time: advert.absoluteEnd)
        }

        BitLog.d("Resuming player")
        play()
    }

    public func skipAdBreak() {
        BitLog.d("YoSpace analytics unsuppressed")
        yospacesession?.suppressAnalytics(false)

        // Seek to end of ad break
        if let adBreak = activeAdBreak {
            BitLog.d("Skipping ad break")
            // Add increment of 0.25 to make sure we land back in main content
            forceSeek(time: adBreak.absoluteEnd + 0.25)
        }

        BitLog.d("Resuming player")
        play()
    }

    public func sessionAdFree() {
        BitLog.d("Session ad free")
        for listener in yospaceListeners {
            listener.onTrueXAdFree()
        }
    }
}

// MARK: - YSAnalyticsObserver

public extension BitmovinYospacePlayer {
    func addYospaceAnalyticEventListener() {
        BitLog.d("Register callbacks for analytic events")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertBreakDidStart),
                                               name: NSNotification.Name.YOAdvertBreakStart,
                                               object: yospacesession)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertDidStart),
                                               name: NSNotification.Name.YOAdvertStart,
                                               object: yospacesession)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertDidEnd),
                                               name: NSNotification.Name.YOAdvertEnd,
                                               object: yospacesession)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(advertBreakDidEnd),
                                               name: NSNotification.Name.YOAdvertBreakEnd,
                                               object: yospacesession)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackingEventDidOccur),
                                               name: NSNotification.Name.YOTrackingEvent,
                                               object: yospacesession)
    }

    @objc func advertBreakDidStart(notification: NSNotification) {
        BitLog.d("YoSpace advertBreakDidStart: \(notification)")
        if let dict = notification.userInfo as NSDictionary? {
            if let adBreak = dict[YOAdBreakKey] as? YOAdBreak, !isLive {
                handleAdBreakEvent(adBreak)
            }
        }
    }

    @objc func advertDidStart(notification: NSNotification) -> [Any]? {
        BitLog.d("YoSpace advertDidStart: \(notification)")

        if isLive, activeAdBreak == nil, let currentAdBreak = yospacesession?.currentAdBreak() {
            handleAdBreakEvent(currentAdBreak)
        }

        var advert: YOAdvert?
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
                pause()

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
                    width: CGFloat(Double(creative.property("width")?.value ?? "0.0")!),
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
                    width: CGFloat(Double(creative.property("width")?.value ?? "0.0")!),
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
            listener.onAdStarted?(adStartedEvent, player: self)
        }

        return []
    }

    @objc func advertDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertDidEnd")

        if let dict = notification.userInfo as NSDictionary? {
            if let YOAd = dict[YOAdvertKey] as? YOAdvert {
                let ad = createActiveAd(advert: YOAd)

                BitLog.d("Emitting AdFinishedEvent")
                for listener: PlayerListener in listeners {
                    listener.onAdFinished?(AdFinishedEvent(ad: ad), player: self)
                }
            }
        }

        activeAd = nil
    }

    @objc func advertBreakDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertBreakDidEnd")

        if let dict = notification.userInfo as NSDictionary? {
            if let YOAdBreak = dict[YOAdBreakKey] as? YOAdBreak, !isLive {
                let adBreak = createActiveAdBreak(adBreak: YOAdBreak)

                BitLog.d("Emitting AdBreakFinishedEvent")
                for listener: PlayerListener in listeners {
                    listener.onAdBreakFinished?(AdBreakFinishedEvent(adBreak: adBreak), player: self)
                }
            }
        }

        activeAdBreak = nil
    }

    @objc func trackingEventDidOccur(notification: NSNotification) {
        BitLog.d("YoSpace trackingEventDidOccur: \(notification)")

        if let dict = notification.userInfo as NSDictionary? {
            if let event = dict[YOEventNameKey] as? String {
                switch event {
                case "firstQuartile":
                    onAdQuartile(AdQuartileEvent(quartile: .firstQuartile), player: self)
                case "midpoint":
                    onAdQuartile(AdQuartileEvent(quartile: .midpoint), player: self)
                case "thirdQuartile":
                    onAdQuartile(AdQuartileEvent(quartile: .thirdQuartile), player: self)
                default:
                    BitLog.d("Skip event: \(event)")
                }
            }
        }
    }

    func timelineUpdateReceived(_: String) {
        if let timeline = yospacesession?.adBreaks(YOAdBreakType.linearType) as? [YOAdBreak] {
            BitLog.d("YoSpace timelineUpdateReceived: \(timeline.count)")
            adBreaks = timeline
        }
    }

    private func createActiveAd(advert: YOAdvert) -> YospaceAd {
        if let adBreakAd = (activeAdBreak?.ads.compactMap { $0 as? YospaceAd }.first { $0.identifier == advert.identifier }) {
            return adBreakAd
        } else {
            let absoluteTime = currentTime
            var adAbsoluteStart: Double
            var adRelativeStart: Double

            if isLive {
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
        let absoluteTime = currentTime
        var adBreakAbsoluteStart: Double
        var adBreakRelativeStart: Double

        if isLive {
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
            listener.onAdBreakStarted?(adBreakStartEvent, player: self)
        }
    }
}

// MARK: - YSAnalyticsObserver

public extension BitmovinYospacePlayer {
    func sessionDidInitialise(with stream: YOSession) {
        BitLog.d("Session Did Initialise")

        if let timeline = stream.adBreaks(YOAdBreakType.linearType) as? [YOAdBreak] {
            BitLog.d("Initial Ad Breaks Received: \(timeline.count)")
            adBreaks = timeline
        }

        // set the policy handler
        let policy = yospacePlayerPolicy ?? YospacePlayerPolicy(bitmovinYospacePlayerPolicy: DefaultBitmovinYospacePlayerPolicy(self))
        stream.setPlaybackPolicyHandler(policy)

        switch stream.sessionResult {
        case .notInitialised:
            BitLog.e("Not initialized url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            if let sourceConfiguration = sourceConfig, yospaceSourceConfig?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                onWarning(YospaceWarningEvent(errorCode: .notIntialised, message: "Yospace not initialized"), player: self)
                load(sourceConfig: sourceConfiguration)
            } else {
                onError(YospaceErrorEvent(errorCode: .notIntialised, message: "Yospace not initialized"), player: self)
            }
        case .noAnalytics:
            // store the session
            yospacesession = stream

            BitLog.d("No Analytics url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            if let sourceConfiguration = sourceConfig, yospaceSourceConfig?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                onWarning(YospaceWarningEvent(errorCode: .noAnalytics, message: "No analytics"), player: self)
                load(sourceConfig: sourceConfiguration)
            } else {
                onError(YospaceErrorEvent(errorCode: .noAnalytics, message: "No analytics"), player: self)
            }
        case .initialised:
            // store the session
            yospacesession = stream
            // start observing analytic events
            addYospaceAnalyticEventListener()

            BitLog.d("With Analytics url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            let sourceConfig = SourceConfig(url: URL(string: stream.playbackUrl!)!, type: .hls)
            if let drmConfig: DrmConfig = self.sourceConfig?.drmConfig {
                sourceConfig.drmConfig = drmConfig
            }
            load(sourceConfig: sourceConfig)
        default:
            break
        }
    }

    func operationDidFailWithError(_ error: Error) {
        if let sourceConfig = sourceConfig, yospaceSourceConfig?.retryExcludingYospace == true {
            BitLog.w("Attempting to playback the stream url without Yospace")
            onWarning(
                YospaceWarningEvent(errorCode: .unknownError, message: "Unknown Error. Initialize failed with Error:" + error.localizedDescription),
                player: self
            )
            load(sourceConfig: sourceConfig)
        } else {
            onError(
                YospaceErrorEvent(errorCode: .unknownError, message: "Unknown Error. Initialize failed with Error:" + error.localizedDescription),
                player: self
            )
        }
    }
}

// MARK: - PlayerListener

extension BitmovinYospacePlayer: PlayerListener {
    public func onPlay(_ event: PlayEvent, player: Player) {
        BitLog.d("onPlayer: \(event)")

        for listener: PlayerListener in listeners {
            listener.onPlay?(PlayEvent(time: currentTime), player: player)
        }
    }

    public func onPlaying(_ event: PlayingEvent, player: Player) {
        BitLog.d("onPlaying: \(event)")

        if sessionStatus == .notInitialised || sessionStatus == .ready {
            sessionStatus = .playing
            yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStartEvent, playhead: currentTimeWithAds())
        } else {
            yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackResumeEvent, playhead: currentTimeWithAds())
        }
        for listener: PlayerListener in listeners {
            listener.onPlaying?(PlayingEvent(time: currentTime), player: player)
        }
    }

    public func onPaused(_ event: PausedEvent, player: Player) {
        BitLog.d("onPaused: \(event)")

        liveAdPaused = isLive && isAd
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackPauseEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onPaused?(PausedEvent(time: currentTime), player: player)
        }
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent, player: Player) {
        if sessionStatus != .notInitialised {
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetYospaceSession()
        }
        for listener: PlayerListener in listeners {
            listener.onSourceUnloaded?(event, player: player)
        }
    }

    public func onStallStarted(_ event: StallStartedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStallEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onStallStarted?(event, player: player)
        }
    }

    public func onStallEnded(_ event: StallEndedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackContinueEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onStallEnded?(event, player: player)
        }
    }

    public func onWarning(_ event: YospaceWarningEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onEvent?(event, player: player)
        }
    }

    public func onError(_ event: YospaceErrorEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onEvent?(event, player: player)
        }
    }

    public func onReady(_ event: ReadyEvent, player: Player) {
        BitLog.d("onReady: \(event)")

        if sessionStatus == .notInitialised {
            sessionStatus = .ready
        }
        for listener: PlayerListener in listeners {
            listener.onReady?(event, player: player)
        }
    }

    public func onMuted(_ event: MutedEvent, player: Player) {
        yospacesession?.volumeDidChange(player.isMuted)
        for listener: PlayerListener in listeners {
            listener.onMuted?(event, player: player)
        }
    }

    public func onUnmuted(_ event: UnmutedEvent, player: Player) {
        yospacesession?.volumeDidChange(player.isMuted)
        for listener: PlayerListener in listeners {
            listener.onUnmuted?(event, player: player)
        }
    }

    public func onMetadataParsed(_ event: MetadataParsedEvent, player: Player) {
//        BitLog.d("onMetadataParsed: \(event)")

        // Note - this is a workaround for the intermittent missing iOS metadata issue,
        // where on start of the stream, date range metadata is not always being propagated to onMetadata
        // It is surfaced as parsed metadata, so we'll check here if it's the correct type and time, and if so,
        // parse it and track it as an ID3
        //
        // If onMetadata does fire afterwards, it will be ignored by handling in DateRangeEmitter
        if receivedFirstPlayhead == false {
            if yospaceSourceConfig?.yospaceAssetType == .linear {
                if let dateRangeMetadata = event.metadata as? DaterangeMetadata {
                    let metadataTime = String(format: "%.2f", dateRangeMetadata.startDate.timeIntervalSince1970)
                    let currentTime = String(format: "%.2f", currentTimeWithAds())
                    if metadataTime == currentTime {
                        BitLog.d("onMetadataParsed: tracking initial emsg")
                        dateRangeEmitter?.trackEmsg(MetadataEvent(metadata: event.metadata, type: event.metadataType))
                    }
                }
            }
        }

        for listener: PlayerListener in listeners {
            listener.onMetadataParsed?(event, player: player)
        }
    }

    public func onMetadata(_ event: MetadataEvent, player: Player) {
//        BitLog.d("onMetadata: \(event)")

        if yospaceSourceConfig?.yospaceAssetType == .linear {
            if event.metadataType == .ID3 {
                trackId3(event)
            } else if event.metadataType == .daterange {
                dateRangeEmitter?.trackEmsg(event)
            }
        }
        for listener: PlayerListener in listeners {
            listener.onMetadata?(event, player: player)
        }
    }

    func trackId3(_ event: MetadataEvent) {
        guard let meta = YOTimedMetadata.createFromMetadata(event: event) else { return }
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
            yospacesession?.timedMetadataWasCollected(meta)
        }
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStopEvent, playhead: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onPlaybackFinished?(event, player: player)
        }
    }

    public func onDurationChanged(_: DurationChangedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onDurationChanged?(DurationChangedEvent(duration: duration), player: player)
        }
    }

    public func onTimeChanged(_ event: TimeChangedEvent, player: Player) {
        receivedFirstPlayhead = true
        yospacesession?.playheadDidChange(currentTimeWithAds())

        if liveAdPaused {
            if let adBreak = activeAdBreak, let advert = activeAd {
                // Send skip event if live window has moved beyond paused ad
                if event.currentTime > adBreak.absoluteEnd {
                    onAdSkipped(AdSkippedEvent(ad: advert), player: player)
                }
            }
            liveAdPaused = false
        }

        // Send to the normalizer so the date emitter can use the normalized value
        // Future use could propagate to the event as well, for media time
        _ = playheadNormalizer?.normalize(time: currentTimeWithAds())

        for listener: PlayerListener in listeners {
            listener.onTimeChanged?(TimeChangedEvent(currentTime: currentTime), player: player)
        }
    }

    public func onSeek(_ event: SeekEvent, player: Player) {
        var event = event
        for listener: PlayerListener in listeners {
            if let timeline = timeline {
                let position = timeline.absoluteToRelative(time: event.from.time)
                let seekTarget = timeline.absoluteToRelative(time: event.to.time)
                let seekFrom = SeekPosition(source: event.from.source, time: position)
                let seekTo = SeekPosition(source: event.to.source, time: seekTarget)
                event = SeekEvent(from: seekFrom, to: seekTo)
            }
            listener.onSeek?(event, player: player)
        }
    }

    /**
     Unmodified eevents, passing thought to registered listeners
     */
    public func onSeeked(_ event: SeekedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onSeeked?(event, player: player)
        }
    }

    public func onDestroy(_ event: DestroyEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onDestroy?(event, player: player)
        }
    }

    public func onEvent(_ event: Event, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onEvent?(event, player: player)
        }
    }

    public func onAdClicked(_ event: AdClickedEvent, player: Player) {
        BitLog.d("onAdClicked: ")
        for listener: PlayerListener in listeners {
            listener.onAdClicked?(event, player: player)
        }
    }

    public func onAdSkipped(_ event: AdSkippedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onAdSkipped?(event, player: player)
        }
    }

    public func onAdStarted(_ event: AdStartedEvent, player: Player) {
        BitLog.d("onAdStarted: ")
        for listener: PlayerListener in listeners {
            listener.onAdStarted?(event, player: player)
        }
    }

    public func onAdQuartile(_ event: AdQuartileEvent, player: Player) {
        BitLog.d("onAdQuartile: ")
        for listener: PlayerListener in listeners {
            listener.onAdQuartile?(event, player: player)
        }
    }

    public func onCastStart(_ event: CastStartEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastStart?(event, player: player)
        }
    }

    public func onAdFinished(_ event: AdFinishedEvent, player: Player) {
        BitLog.d("onAdFinished: ")
        for listener: PlayerListener in listeners {
            listener.onAdFinished?(event, player: player)
        }
    }

    public func onTimeShift(_ event: TimeShiftEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onTimeShift?(event, player: player)
        }
    }

    public func onAdScheduled(_ event: AdScheduledEvent, player: Player) {
        BitLog.d("onAdScheduled: ")
        for listener: PlayerListener in listeners {
            listener.onAdScheduled?(event, player: player)
        }
    }

    public func onAudioAdded(_ event: AudioAddedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onAudioAdded?(event, player: player)
        }
    }

    public func onVideoDownloadQualityChanged(_ event: VideoDownloadQualityChangedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onVideoDownloadQualityChanged?(event, player: player)
        }
    }

    public func onCastPlaying(_ event: CastPlayingEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastPlaying?(event, player: player)
        }
    }

    public func onCastStarted(_ event: CastStartedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastStarted?(event, player: player)
        }
    }

    public func onCastStopped(_ event: CastStoppedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastStopped?(event, player: player)
        }
    }

    public func onCastAvailable(_ event: CastAvailableEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastAvailable?(event, player: player)
        }
    }

    public func onCastPlaybackFinished(_ event: CastPlaybackFinishedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastPlaybackFinished?(event, player: player)
        }
    }

    public func onCastPaused(_ event: CastPausedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastPaused?(event, player: player)
        }
    }

    public func onTimeShifted(_ event: TimeShiftedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onTimeShifted?(event, player: player)
        }
    }

    public func onAudioChanged(_ event: AudioChangedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onAudioChanged?(event, player: player)
        }
    }

    public func onAudioRemoved(_ event: AudioRemovedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onAudioRemoved?(event, player: player)
        }
    }

    public func onSourceLoaded(_ event: SourceLoadedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onSourceLoaded?(event, player: player)
        }
    }

    public func onSubtitleAdded(_ event: SubtitleAddedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleAdded?(event, player: player)
        }
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent, player: Player) {
        BitLog.d("onAdBreakStarted: ")
        for listener: PlayerListener in listeners {
            listener.onAdBreakStarted?(event, player: player)
        }
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent, player: Player) {
        BitLog.d("onAdBreakFinished: ")
        for listener: PlayerListener in listeners {
            listener.onAdBreakFinished?(event, player: player)
        }
    }

    public func onAdManifestLoaded(_ event: AdManifestLoadedEvent, player: Player) {
        BitLog.d("onAdManifestLoaded: ")
        for listener: PlayerListener in listeners {
            listener.onAdManifestLoaded?(event, player: player)
        }
    }

    public func onCastTimeUpdated(_ event: CastTimeUpdatedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCastTimeUpdated?(event, player: player)
        }
    }

    public func onSubtitleRemoved(_ event: SubtitleRemovedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleRemoved?(event, player: player)
        }
    }

    public func onSubtitleChanged(_ event: SubtitleChangedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onSubtitleChanged?(event, player: player)
        }
    }

    public func onCueEnter(_ event: CueEnterEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCueEnter?(event, player: player)
        }
    }

    public func onCueExit(_ event: CueExitEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onCueExit?(event, player: player)
        }
    }

    public func onDvrWindowExceeded(_ event: DvrWindowExceededEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onDvrWindowExceeded?(event, player: player)
        }
    }

    public func onDownloadFinished(_ event: DownloadFinishedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onDownloadFinished?(event, player: player)
        }
    }

    public func onVideoSizeChanged(_ event: VideoSizeChangedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onVideoSizeChanged?(event, player: player)
        }
    }

    public func onDrmDataParsed(_ event: DrmDataParsedEvent, player: Player) {
        for listener: PlayerListener in listeners {
            listener.onDrmDataParsed?(event, player: player)
        }
    }
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
            sequence: "sequence",
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
