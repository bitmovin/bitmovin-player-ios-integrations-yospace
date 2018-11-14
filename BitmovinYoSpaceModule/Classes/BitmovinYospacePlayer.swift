import UIKit
import BitmovinPlayer
import Yospace

enum SessionStatus: Int {
    case notInitialised
    case ready
    case playing
}

public class BitmovinYospacePlayer: BitmovinPlayer, YSVideoPlayer {
    public required init(streamSource source: URL) {
        super.init(configuration: PlayerConfiguration())
    }

    var sessionManger: YSSessionManager?
    var sessionStatus: SessionStatus = .notInitialised
    var adPlaying = false
    var yospaceSourceConfiguration: YospaceSourceConfiguration?
    var sourceConfiguration: SourceConfiguration?
    var listeners: [PlayerListener] = []
    private var yospaceListeners: [YospaceListener] = []

    public var rate: Float {
        get {
            return playbackSpeed
        }
        set (rate) {

        }
    }

    public override init(configuration: PlayerConfiguration) {
        sessionStatus = .notInitialised
        super.init(configuration: configuration)
        self.add(listener: self)
    }
    
    public override func destroy() {
        resetSessionManager();
        super.destroy()
    }

    public func load(sourceConfiguration: SourceConfiguration, yospaceSourceConfiguration: YospaceSourceConfiguration) {
        resetSessionManager();
        self.yospaceSourceConfiguration = yospaceSourceConfiguration
        self.sourceConfiguration = sourceConfiguration
        let yospaceProperties = YSSessionProperties()
        yospaceProperties.analyticsUserAgent = yospaceSourceConfiguration.userAgent
        if let timeout = yospaceSourceConfiguration.timeout {
            yospaceProperties.timeout = timeout
        }

        if(yospaceSourceConfiguration.debug) {
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
                break
            case .linearStartOver:
                loadNonLinearStartOver(url: url, yospaceProperties: yospaceProperties)
                break
            case .vod:
                loadVOD(url: url, yospaceProperties: yospaceProperties)
                break
        }
    }
    
    func resetSessionManager(){
        self.sessionManger?.shutdown()
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
    
    public func clickThroughPressed(){
        sessionManger?.linearClickThroughDidOccur();
    }

    public override func add(listener: PlayerListener) {
        listeners.append(listener)
        super.add(listener: listener)
    }

    public override func remove(listener: PlayerListener) {
        listeners = listeners.filter { $0 !== listener }
        super.remove(listener: listener)
    }

    public override func skipAd() {
        if(sessionStatus != .notInitialised) {
            //TODO skipAd
        } else {
            return super.skipAd()
        }
    }

    public override var isAd: Bool {
        get {
            if(sessionStatus != .notInitialised) {
                return adPlaying
            } else {
                return super.isAd
            }
        }
    }

    func handleError(code: UInt, message: String) {
        for listener: YospaceListener in yospaceListeners {
            listener.onYospaceError(event: ErrorEvent(code: code, message: message))
        }
    }
    
    public func add(yospaceListener: YospaceListener){
        yospaceListeners.append(yospaceListener)
    }
    
    public func remove(yospaceListener: YospaceListener){
        yospaceListeners = yospaceListeners.filter { $0 !== yospaceListener }
    }
    
}

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
        var clickThroughUrl:URL = URL(string: "http://google.com")!
        
        if (advert.linearCreativeElement().linearClickthroughURL() != nil) {
            clickThroughUrl = advert.linearCreativeElement().linearClickthroughURL()!
        }

        let adStartedEvent: AdStartedEvent = AdStartedEvent(clickThroughUrl: clickThroughUrl, clientType: .IMA, indexInQueue: 0, duration: advert.advertDuration(), timeOffset: advert.advertStart(), skipOffset: 1, position: "0")
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
}

extension BitmovinYospacePlayer: YSSessionManagerObserver {
    public func sessionDidInitialise(_ sessionManager: YSSessionManager, with stream: YSStream) {
        self.sessionManger = sessionManager
        self.sessionManger?.subscribe(toAnalyticEvents: self)

        //TODO create policy
        // create a playback policy object
        //        let policyHandler = YOPlayerPolicyImpl()
        //        self.theSessionManager?.setPlayerPolicyDelegate(policyHandler)

        do {
            try self.sessionManger?.setVideoPlayer(self)
        } catch {
            handleError(code: YospaceErrorCode.invalidPlayer.rawValue, message: "Invalid video player added to session manger")
        }

        switch sessionManager.initialisationState {
        case .notInitialised:
            handleError(code: YospaceErrorCode.notIntialised.rawValue, message: "Not Intialized")
            NSLog("Not initialized url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            break
        case .initialisedNoAnalytics:
            handleError(code: YospaceErrorCode.noAnalytics.rawValue, message: "No analytics")
            NSLog("No Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            break
        case .initialisedWithAnalytics:
            NSLog("With Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")

            let sourceConfig = SourceConfiguration()
            sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: stream.streamSource())))
            load(sourceConfiguration: sourceConfig)
            break
        default:
            break
        }
    }

    public func operationDidFailWithError(_ error: Error) {
        handleError(code: YospaceErrorCode.unknownError.rawValue, message: "Unknown Error. Initialize failed with Error")
    }
}

extension BitmovinYospacePlayer: PlayerListener {
    public func onPlay(_ event: PlayEvent) {
        NSLog("On Play")

        if (sessionStatus == .notInitialised || sessionStatus == .ready) {
            sessionStatus = .playing
            let dictionary = [kYoPlayheadKey: currentTime]
            self.notify(dictionary: dictionary, name: YoPlaybackStartedNotification)
        } else {
            let dictionary = [kYoPlayheadKey: currentTime]
            self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
        }

    }

    public func onPaused(_ event: PausedEvent) {
        NSLog("On Paused")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackPausedNotification)
    }

    public func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        NSLog("On Source Unloaded")
        if(sessionStatus != .notInitialised){
            // the yospace sessionManager.shutdown() call is asynchronous. If the user just calls `load()` on second playback without calling `unload()` we end up canceling both the old session and the new session. This if statement keeps track of that
            resetSessionManager();
        }
    }

    public func onStallStarted(_ event: StallStartedEvent) {
        NSLog("On Stall Started")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackStalledNotification)
    }

    public func onStallEnded(_ event: StallEndedEvent) {
        NSLog("On Stall Ended")
        let dictionary = [kYoPlayheadKey: currentTime]
        self.notify(dictionary: dictionary, name: YoPlaybackResumedNotification)
    }

    public func onError(_ event: ErrorEvent) {
        NSLog("On Error")
    }

    public func onReady(_ event: ReadyEvent) {
        NSLog("On Ready")
        if (sessionStatus == .notInitialised) {
            sessionStatus = .ready
            self.notify(dictionary: Dictionary(), name: YoPlaybackReadyNotification)
        }
    }

    public func onMuted(_ event: MutedEvent) {
        let dictionary = [kYoMutedKey: Bool(self.isMuted)]
        self.notify(dictionary: dictionary, name: YoPlaybackVolumeChangedNotification)
    }

    public func onUnmuted(_ event: UnmutedEvent) {
        let dictionary = [kYoMutedKey: Bool(self.isMuted)]
        self.notify(dictionary: dictionary, name: YoPlaybackVolumeChangedNotification)
    }

    public func onMetadata(_ event: MetadataEvent) {
        let meta = YSTimedMetadata.createFromMetadata(event: event)
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (meta.type.count != 0) {
            let dictionary = [kYoMetadataKey: meta]
            self.notify(dictionary: dictionary, name: YoTimedMetadataNotification)
        }
    }

    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        let dictionary = [kYoPlayheadKey: Int(currentTime), kYoCompletedKey: Int(truncating: true)]
        self.notify(dictionary: dictionary, name: YoPlaybackEndedNotification)
    }

    func notify(dictionary: Dictionary<String, Any>, name: String) {
        NSLog("Firing %@ Notification", name)

        DispatchQueue.main.async(execute: {() -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self, userInfo: dictionary)
        })
    }
}
