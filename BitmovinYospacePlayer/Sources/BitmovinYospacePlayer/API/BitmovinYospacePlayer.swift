import BitmovinPlayerCore
import Combine
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

    public var duration: TimeInterval {
        guard isAd, let activeAd else {
            return player.duration - adBreaks.reduce(0) { $0 + $1.duration }
        }

        return activeAd.duration
    }

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

    public var source: Source? { return player.source }

    public var maxTimeShift: TimeInterval { return player.maxTimeShift }

    public var timeShift: TimeInterval {
        get { return player.timeShift }
        set { player.timeShift = newValue }
    }

    public var availableSubtitles: [SubtitleTrack] { return player.availableSubtitles }

    public var subtitle: SubtitleTrack { return player.subtitle }

    public var availableAudio: [AudioTrack] { return player.availableAudio }

    public var audio: AudioTrack? { return player.audio }

    public var isAd: Bool {
        if sessionStatus != .notInitialised {
            return activeAd != nil
        } else {
            return player.isAd
        }
    }

    public var isAirPlayActive: Bool { return player.isAirPlayActive }

    public var isAirPlayAvailable: Bool { return player.isAirPlayAvailable }

    public var allowsAirPlay: Bool {
        get {
            player.allowsAirPlay
        }
        set {
            player.allowsAirPlay = newValue
        }
    }

    public var availableVideoQualities: [VideoQuality] { return player.availableVideoQualities }

    public var videoQuality: VideoQuality? { return player.videoQuality }

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

    public var playlist: PlaylistApi { return player.playlist }

    public lazy var ads: BitmovinPlayerCore.AdvertisingApi = {
        return BitmovinAdsApiProxy(yospacePlayer: self)
    }()

    public var isCasting: Bool { return player.isCasting }

    public var isWaitingForDevice: Bool { return player.isWaitingForDevice }

    public var isCastAvailable: Bool { return player.isCastAvailable }

    public var isOutputObscured: Bool { return player.isOutputObscured }

    @available(iOS 15, tvOS 15, *)
    public var sharePlay: SharePlayApi { return player.sharePlay }

    public var _modules: _PlayerModulesApi { player._modules }

    public var latency: BitmovinPlayerCore.LatencyApi { player.latency }

    public var thumbnails: BitmovinPlayerCore.ThumbnailsApi { player.thumbnails }

    public var events: PlayerEventsApi {
        bitmovinEventsApiProxy
    }

    /// Namespace to subscribe to ``BitmovinYospaceEvent`` using Combine publishers.
    public var yospaceEvents: YospaceEventsApi {
        yospaceEventsApi
    }

    // MARK: - Bitmovin Player methods

    public func load(sourceConfig: SourceConfig) {
        player.load(sourceConfig: sourceConfig)
    }

    public func load(source: Source) {
        player.load(source: source)
    }

    public func load(playlistConfig: PlaylistConfig) {
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
    public func addSubtitle(track subtitleTrack: SubtitleTrack) {
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

    @available(*, deprecated, renamed: "player.ads.schedule")
    public func scheduleAd(adItem: AdItem) {
        BitLog.w("player.scheduleAd is deprecated. Please use player.ads.schedule instead.")
        ads.schedule(adItem: adItem)
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

    @available(*, deprecated, renamed: "player.ads.register")
    public func registerAdContainer(_ adContainer: UIView) {
        BitLog.w("player.registerAdContainer is deprecated. Please use player.ads.register instead.")
        ads.register(adContainer: adContainer)
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
    var yospacePlayerPolicy: YospacePlayerPolicy?
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
    private var truexRenderer: BitmovinTruexRenderer?
    private let eventBus: EventBus
    private let bitmovinEventsApiProxy: BitmovinEventsApiProxy
    private let yospaceEventsApi: DefaultYospaceEventsApi

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
        let eventBus = EventBus(player: player)
        self.eventBus = eventBus
        yospaceEventsApi = DefaultYospaceEventsApi(eventBus: eventBus)
        bitmovinEventsApiProxy = BitmovinEventsApiProxy(eventBus: eventBus)

        super.init()
        eventBus.register(yospacePlayer: self)

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
        dateRangeEmitter = DateRangeEmitter(
            player: self,
            eventBus: eventBus,
            normalizer: playheadNormalizer
        )
    }

    public func destroy() {
        resetYospaceSession()
        integrationListeners.removeAll()
        player.destroy()
        eventBus.destroy()
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
        if let truexConfiguration = truexConfiguration {
            self.truexConfiguration = truexConfiguration
            truexRenderer = BitmovinTruexRenderer(configuration: truexConfiguration, eventDelegate: self)
        } else {
            self.truexConfiguration = nil
            truexRenderer = nil
        }

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
            emitYoSpaceError(YospaceErrorEvent(errorCode: .invalidSource, message: "Invalid source provided. Yospace URL must be HLS"), player: self)
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
        eventBus.add(playerListener: listener)
    }

    public func remove(listener: PlayerListener) {
        eventBus.remove(playerListener: listener)
    }

    public func add(yospaceListener: YospaceListener) {
        eventBus.add(yospaceListener: yospaceListener)
    }

    public func remove(yospaceListener: YospaceListener) {
        eventBus.remove(yospaceListener: yospaceListener)
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
        truexRenderer?.stopRenderer()
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

        let event = AdTimelineChangedEvent(
            timeline: timeline
        )

        eventBus.emit(event: event)
    }

    @available(*, deprecated, renamed: "player.ads.skip")
    public func skipAd() {
        BitLog.w("player.skipAd is deprecated. Please use player.ads.skip instead.")
        ads.skip()
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
        eventBus.emit(event: TrueXAdFreeEvent())
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
        eventBus.emit(event: adStartedEvent)

        return []
    }

    @objc func advertDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertDidEnd")

        guard let activeAd else { return }

        BitLog.d("Emitting AdFinishedEvent")
        let adFinishedEvent = AdFinishedEvent(ad: activeAd)
        eventBus.emit(event: adFinishedEvent)

        self.activeAd = nil
    }

    @objc func advertBreakDidEnd(notification: NSNotification) {
        BitLog.d("YoSpace advertBreakDidEnd")


        guard let activeAdBreak else { return }

        BitLog.d("Emitting AdBreakFinishedEvent")
        let adBreakFinishedEvent = AdBreakFinishedEvent(adBreak: activeAdBreak)
        eventBus.emit(event: adBreakFinishedEvent)

        self.activeAdBreak = nil
    }

    @objc func trackingEventDidOccur(notification: NSNotification) {
        BitLog.d("YoSpace trackingEventDidOccur: \(notification)")

        if let dict = notification.userInfo as NSDictionary? {
            if let event = dict[YOEventNameKey] as? String {
                switch event {
                case "firstQuartile":
                    emitPreprocessedEvent(event: AdQuartileEvent(quartile: .firstQuartile), player: self)
                case "midpoint":
                    emitPreprocessedEvent(event: AdQuartileEvent(quartile: .midpoint), player: self)
                case "thirdQuartile":
                    emitPreprocessedEvent(event: AdQuartileEvent(quartile: .thirdQuartile), player: self)
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
        eventBus.emit(event: adBreakStartEvent)
    }

    private func emitYoSpaceError(_ event: YospaceErrorEvent, player: Player) {
        eventBus.emit(event: event)
    }

    private func emitYoSpaceWarning(_ event: YospaceWarningEvent, player: Player) {
        eventBus.emit(event: event)
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

        switch stream.sessionState {
        case .noAnalytics:
            // store the session
            yospacesession = stream

            BitLog.d("No Analytics url:\(stream.playbackUrl ?? "none") itemId:\(stream.identifier ?? "none")")
            if let sourceConfiguration = sourceConfig, yospaceSourceConfig?.retryExcludingYospace == true {
                BitLog.w("Attempting to playback the stream url without Yospace")
                emitYoSpaceWarning(YospaceWarningEvent(errorCode: .noAnalytics, message: "No analytics"), player: self)
                load(sourceConfig: sourceConfiguration)
            } else {
                emitYoSpaceError(YospaceErrorEvent(errorCode: .noAnalytics, message: "No analytics"), player: self)
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
            emitYoSpaceWarning(
                YospaceWarningEvent(errorCode: .unknownError, message: "Unknown Error. Initialize failed with Error:" + error.localizedDescription),
                player: self
            )
            load(sourceConfig: sourceConfig)
        } else {
            emitYoSpaceError(
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

        let playEvent = PlayEvent(time: currentTime)
        emitPreprocessedEvent(event: playEvent, player: player)
    }

    public func onPlaying(_ event: PlayingEvent, player: Player) {
        BitLog.d("onPlaying: \(event)")

        if sessionStatus == .notInitialised || sessionStatus == .ready {
            sessionStatus = .playing
            yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStartEvent, playhead: currentTimeWithAds())
        } else {
            yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackResumeEvent, playhead: currentTimeWithAds())
        }

        let playingEvent = PlayingEvent(time: currentTime)
        emitPreprocessedEvent(event: playingEvent, player: player)
    }

    public func onPaused(_ event: PausedEvent, player: Player) {
        BitLog.d("onPaused: \(event)")

        liveAdPaused = isLive && isAd
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackPauseEvent, playhead: currentTimeWithAds())

        let pausedEvent = PausedEvent(time: currentTime)
        emitPreprocessedEvent(event: pausedEvent, player: player)
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent, player: Player) {
        if sessionStatus != .notInitialised {
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetYospaceSession()
        }

        emitPreprocessedEvent(event: event, player: player)
    }

    public func onStallStarted(_ event: StallStartedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStallEvent, playhead: currentTimeWithAds())

        emitPreprocessedEvent(event: event, player: player)
    }

    public func onStallEnded(_ event: StallEndedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackContinueEvent, playhead: currentTimeWithAds())

        emitPreprocessedEvent(event: event, player: player)
    }

    public func onReady(_ event: ReadyEvent, player: Player) {
        BitLog.d("onReady: \(event)")

        if sessionStatus == .notInitialised {
            sessionStatus = .ready
        }

        emitPreprocessedEvent(event: event, player: player)
    }

    public func onMuted(_ event: MutedEvent, player: Player) {
        yospacesession?.volumeDidChange(player.isMuted)
        emitPreprocessedEvent(event: event, player: player)
    }

    public func onUnmuted(_ event: UnmutedEvent, player: Player) {
        yospacesession?.volumeDidChange(player.isMuted)
        emitPreprocessedEvent(event: event, player: player)
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

        emitPreprocessedEvent(event: event, player: player)
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

        emitPreprocessedEvent(event: event, player: player)
    }

    func trackId3(_ event: MetadataEvent) {
        guard let meta = YOTimedMetadata.createFromMetadata(event: event) else { return }
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (!meta.type.isEmpty) {
            yospacesession?.timedMetadataWasCollected(meta)
        }
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent, player: Player) {
        yospacesession?.playerEventDidOccur(YOPlayerEvent.playbackStopEvent, playhead: currentTimeWithAds())

        emitPreprocessedEvent(event: event, player: player)
    }

    public func onDurationChanged(_: DurationChangedEvent, player: Player) {
        let durationChangedEvent = DurationChangedEvent(duration: duration)
        emitPreprocessedEvent(event: durationChangedEvent, player: player)
    }

    public func onTimeChanged(_ event: TimeChangedEvent, player: Player) {
        receivedFirstPlayhead = true
        yospacesession?.playheadDidChange(currentTimeWithAds())

        if liveAdPaused {
            if let adBreak = activeAdBreak, let advert = activeAd {
                // Send skip event if live window has moved beyond paused ad
                if event.currentTime > adBreak.absoluteEnd {
                    emitPreprocessedEvent(
                        event: AdSkippedEvent(ad: advert),
                        player: player
                    )
                }
            }
            liveAdPaused = false
        }

        // Send to the normalizer so the date emitter can use the normalized value
        // Future use could propagate to the event as well, for media time
        _ = playheadNormalizer?.normalize(time: currentTimeWithAds())

        let timeChangedEvent = TimeChangedEvent(currentTime: currentTime)
        emitPreprocessedEvent(event: timeChangedEvent, player: player)
    }

    public func onSeek(_ event: SeekEvent, player: Player) {
        var event = event
        if let timeline = timeline {
            let position = timeline.absoluteToRelative(time: event.from.time)
            let seekTarget = timeline.absoluteToRelative(time: event.to.time)
            let seekFrom = SeekPosition(source: event.from.source, time: position)
            let seekTo = SeekPosition(source: event.to.source, time: seekTarget)
            event = SeekEvent(from: seekFrom, to: seekTo)
        }

        emitPreprocessedEvent(event: event, player: player)
    }

    // Unmodified events, passing thought to registered listeners
    public func onEvent(_ event: Event, player: Player) {
        let selector = buildSelector(for: event, sender: player)

        // Filter out events which are preprocessed in this component
        guard !responds(to: selector) else {
            return
        }

        eventBus.emit(event: event)
    }

    private func emitPreprocessedEvent(event: Event, player: Player) {
        let selector = buildSelector(for: event, sender: player)

        eventBus.emit(event: event)
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
            mediaFileUrl: URL(string: interactiveCreative?.source ?? ""),
            skippableAfter: skipOffset,
            clickThroughUrlOpened: { }
        )
    }
}

private func buildSelector(for event: Event, sender: Any) -> Selector {
    let suffix: String
    switch sender {
    case is Player:
        suffix = "player:"
    case is Source:
        suffix = "source:"
    case is PlayerView:
        suffix = "view:"
    default:
        fatalError("Unsupported sender was used: \(type(of: sender))")
    }
    var selectorString = String(describing: type(of: event))
    selectorString = selectorString.replacingOccurrences(of: "Event", with: "")
    selectorString = selectorString.replacingOccurrences(of: "_", with: "")
    selectorString = selectorString.replacingOccurrences(of: "BMP", with: "")
    selectorString = "on\(selectorString):\(suffix)"
    return Selector(selectorString)
}
