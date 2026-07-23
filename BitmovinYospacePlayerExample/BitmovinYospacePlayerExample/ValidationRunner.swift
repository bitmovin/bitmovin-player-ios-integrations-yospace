import BitmovinPlayerCore
import BitmovinYospacePlayer
import Foundation

struct ValidationConfig {
    enum Asset: String {
        case vod = "VOD"
        case dvrLive = "DVR_LIVE"

        var displayName: String {
            switch self {
            case .vod: "VOD"
            case .dvrLive: "DVR Live"
            }
        }

        var initializationLabel: String {
            switch self {
            case .vod: "N/A"
            case .dvrLive: "DIRECT"
            }
        }
    }

    enum TestCase: String {
        case adBreak = "AD_BREAK"
        case twoSessions = "TWO_SESSIONS"

        var displayName: String {
            switch self {
            case .adBreak: "Test 1"
            case .twoSessions: "Test 2"
            }
        }
    }

    let asset: Asset
    let testCase: TestCase

    var statusLabel: String {
        "\(asset.displayName), \(testCase.displayName)"
    }

    static func from(arguments: [String]) -> ValidationConfig? {
        guard arguments.contains("--validation-mode") else { return nil }

        let asset = value(after: "--asset", in: arguments)
            .flatMap(Asset.init(rawValue:)) ?? .dvrLive
        let testCase = value(after: "--test-case", in: arguments)
            .flatMap(TestCase.init(rawValue:)) ?? .adBreak

        return ValidationConfig(asset: asset, testCase: testCase)
    }

    private static func value(after key: String, in arguments: [String]) -> String? {
        guard let keyIndex = arguments.firstIndex(of: key) else { return nil }
        let valueIndex = arguments.index(after: keyIndex)
        guard valueIndex < arguments.endIndex else { return nil }
        return arguments[valueIndex]
    }
}

final class ValidationRunner {
    private static let vodURL = URL(
        string: "https://csm-e-sdk-validation.bln1.yospace.com/csm/access/156611618/c2FtcGxlL21hc3Rlci5tM3U4?yo.av=3"
    )!
    private static let dvrLiveURL = URL(
        string: "https://csm-e-sdk-validation.bln1.yospace.com/csm/extlive/yosdk02,hls-ts-pre.m3u8?yo.br=false&yo.av=4&yo.lp=true&yo.pdt=true&yo.lpa=dur"
    )!
    private static let twoSessionsPlaybackConfirmation: TimeInterval = 5
    private static let betweenSessionsDelay: TimeInterval = 1

    let config: ValidationConfig

    private let player: BitmovinYospacePlayer
    private var timeoutWorkItem: DispatchWorkItem?
    private var sessionIndex = 0
    private var playbackStartedForSession = false
    private var adBreakStarted = false
    private var inAdBreak = false
    private var pendingUnload = false
    private var awaitingUnload = false
    private var started = false
    private var completed = false

    init(config: ValidationConfig, player: BitmovinYospacePlayer) {
        self.config = config
        self.player = player
    }

    func start() {
        guard !started else { return }
        started = true

        log("START asset=\(config.asset.rawValue) init=\(config.asset.initializationLabel) testCase=\(config.testCase.rawValue)")

        let timeout = config.testCase == .adBreak ? 15 * 60.0 : 7 * 60.0
        let workItem = DispatchWorkItem { [weak self] in self?.fail(reason: "timeout") }
        timeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
        loadNextSession()
    }

    func onPlayerEvent(_ event: PlayerEvent) {
        switch event {
        case is PlayingEvent:
            onPlaybackStarted()
        case is AdBreakStartedEvent:
            onAdBreakStarted()
        case is AdBreakFinishedEvent:
            onAdBreakFinished()
        case let event as PlayerErrorEvent:
            log("PLAYER_ERROR code=\(event.errorCode) message=\(event.message)")
            fail(reason: "player-error")
        default:
            break
        }
    }

    func onSourceEvent(_ event: SourceEvent) {
        if event is SourceUnloadedEvent {
            onStreamUnloaded()
        }
    }

    func onYospaceEvent(_ event: BitmovinYospaceEvent) {
        if let event = event as? YospaceErrorEvent {
            log("YOSPACE_ERROR name=\(event.name) message=\(event.message)")
            fail(reason: "yospace-error")
        }
    }

    private func onPlaybackStarted() {
        guard !completed, !playbackStartedForSession else { return }
        playbackStartedForSession = true
        log("PLAYBACK_STARTED session=\(sessionIndex)")

        if config.testCase == .twoSessions {
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.twoSessionsPlaybackConfirmation) { [weak self] in
                self?.requestUnload(reason: "playback-confirmed")
            }
        }
    }

    private func onAdBreakStarted() {
        guard !completed else { return }
        inAdBreak = true
        adBreakStarted = true
        log("AD_BREAK_STARTED session=\(sessionIndex)")
    }

    private func onAdBreakFinished() {
        guard !completed else { return }
        inAdBreak = false
        log("AD_BREAK_FINISHED session=\(sessionIndex)")

        if config.testCase == .adBreak, adBreakStarted {
            requestUnload(reason: "ad-break-finished")
        } else if pendingUnload {
            requestUnload(reason: "pending-after-ad-break")
        }
    }

    private func onStreamUnloaded() {
        guard !completed, awaitingUnload else { return }
        awaitingUnload = false
        log("STREAM_UNLOADED session=\(sessionIndex)")

        switch config.testCase {
        case .adBreak:
            pass()
        case .twoSessions where sessionIndex < 2:
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.betweenSessionsDelay) { [weak self] in
                self?.loadNextSession()
            }
        case .twoSessions:
            pass()
        }
    }

    private func loadNextSession() {
        guard !completed else { return }

        sessionIndex += 1
        playbackStartedForSession = false
        adBreakStarted = false
        inAdBreak = false
        pendingUnload = false
        awaitingUnload = false
        log("LOAD_STREAM session=\(sessionIndex)")

        let url = config.asset == .vod ? Self.vodURL : Self.dvrLiveURL
        let assetType: YospaceAssetType = config.asset == .vod ? .vod : .dvrLive
        player.load(
            sourceConfig: SourceConfig(url: url, type: .hls),
            yospaceSourceConfig: YospaceSourceConfig(yospaceAssetType: assetType)
        )
    }

    private func requestUnload(reason: String) {
        guard !completed, !awaitingUnload else { return }

        if inAdBreak {
            pendingUnload = true
            log("WAITING_FOR_AD_BREAK_END session=\(sessionIndex) reason=\(reason)")
            return
        }

        pendingUnload = false
        awaitingUnload = true
        log("UNLOAD_STREAM session=\(sessionIndex) reason=\(reason)")
        player.unload()
    }

    private func pass() {
        completed = true
        timeoutWorkItem?.cancel()
        log("PASS testCase=\(config.testCase.rawValue)")
    }

    private func fail(reason: String) {
        guard !completed else { return }
        completed = true
        timeoutWorkItem?.cancel()
        log("FAIL reason=\(reason) asset=\(config.asset.rawValue) init=\(config.asset.initializationLabel) testCase=\(config.testCase.rawValue)")
    }

    private func log(_ message: String) {
        NSLog("YospaceValidation %@", message)
    }
}
