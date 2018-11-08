import UIKit
import BitmovinPlayer
import Yospace

enum SessionStatus : Int
{
    case notInitialised
    case initialisedReady
    case initialisedPlaying
}

public class BitmovinYospacePlayer:BitmovinPlayer {

    var ysVideoPlayer:YoSpacePlayer;
    var sessionManger:YSSessionManager?
    var sessionInitialized:SessionStatus
    var yospaceSourceConfiguration:YospaceSourceConfiguration?
    var sourceConfiguration:SourceConfiguration?

    public override init(configuration: PlayerConfiguration) {
        sessionInitialized = .notInitialised
        ysVideoPlayer = YoSpacePlayer(streamSource: URL(string: "http://google.com")!)
        super.init(configuration: configuration);
        ysVideoPlayer.player = self
        self.add(listener: self);
   
    }
    
    public func load(sourceConfiguration:SourceConfiguration, yospaceSourceConfiguration: YospaceSourceConfiguration){
        sessionInitialized = .notInitialised
        self.yospaceSourceConfiguration = yospaceSourceConfiguration
        self.sourceConfiguration = sourceConfiguration
        let yospaceProperties = YSSessionProperties()
        yospaceProperties.analyticsUserAgent = yospaceSourceConfiguration.userAgent;
        yospaceProperties.timeout = yospaceSourceConfiguration.timeout
        
        if(yospaceSourceConfiguration.debug){
            let combined = YSEDebugFlags(rawValue: YSEDebugFlags.DEBUG_ID3TAG.rawValue | YSEDebugFlags.DEBUG_REPORTS.rawValue)
            YSSessionProperties.add(_:combined!)

        }
        guard let url:URL = self.sourceConfiguration?.firstSourceItem?.hlsSource?.url else {
            //TODO throw error
            return
        }
        
        switch yospaceSourceConfiguration.yoSpaceAssetType {
            case .linear:
                loadLive(url: url, yospaceProperties: yospaceProperties)
                break
            case .linearStartOver:
                loadNonLinearStartOver(url: url, yospaceProperties: yospaceProperties);
                break
            case .vod:
                loadVOD(url: url, yospaceProperties: yospaceProperties)
                break
        }
    }
    
    public func loadVOD(url: URL, yospaceProperties: YSSessionProperties){
        YSSessionManager.create(forVoD: url, properties: yospaceProperties, delegate: self)
    }
    
    public func loadLive(url: URL, yospaceProperties: YSSessionProperties){
        YSSessionManager.create(forLive: url, properties: yospaceProperties, delegate: self)
    }
    
    public func loadNonLinearStartOver(url: URL, yospaceProperties: YSSessionProperties){
        YSSessionManager.create(forNonLinearStartOver: url, properties: yospaceProperties, delegate: self)
    }
    
    public func operationDidFailWithError(_ error: Error) {
        print("Operation did fail with error");
    }
    
    public override func add(listener: PlayerListener) {
        super.add(listener: listener)
    }
    
    public override func remove(listener: PlayerListener) {
        super.remove(listener: listener)
    }
    
    /**
     YSAnalyticsObserver content analytics
     */
    
    public func contentDidEnd(_ playheadPosition: TimeInterval) {
        print("Content did end");
    }
    
    public func contentDidPause(_ playheadPosition: TimeInterval) {
        print("Content did pause");
    }
    
    public func contentDidStart(_ playheadPosition: TimeInterval) {
        print("Content did start");
    }
    
    public func contentDidResume(_ playheadPosition: TimeInterval) {
        print("Content did resume");
    }
}

extension BitmovinYospacePlayer: YSAnalyticObserver {
    public func advertBreakDidStart(_ adBreak: YSAdBreak) {
        print("Advert Break Did Start");
    }
    
    public func advertBreakDidEnd(_ adBreak: YSAdBreak) {
        print("Advert Break Did End");
    }
    
    public func advertDidStart(_ advert: YSAdvert) -> [Any]? {
        print("Advert Did Start");
        return []
    }
    
    public func advertDidEnd(_ advert: YSAdvert) {
        print("Advert Did End");
    }
    
    public func trackingEventDidOccur(_ event: YSETrackingEvent, for advert: YSAdvert) {
        print("Tracking Event Did Occur ", YospaceUtil.trackingEventString(event: event));
    }
    
    public func linearClickThroughDidOccur(_ linearCreative: YSLinearCreative) {
        
    }
    
    public func nonlinearClickThroughDidOccur(_ nonlinearCreative: YSNonLinearCreative) {
        
    }
}


extension BitmovinYospacePlayer: YSSessionManagerObserver {
    public func sessionDidInitialise(_ sessionManager: YSSessionManager, with stream: YSStream) {
        
        self.sessionManger = sessionManager
        
        // start observing analytic events
        self.sessionManger?.subscribe(toAnalyticEvents: self)
        
        // create a playback policy object
        //        let policyHandler = YOPlayerPolicyImpl()
        //        self.theSessionManager?.setPlayerPolicyDelegate(policyHandler)
        
        // pass the video player reference to the session manager
        do{
            try self.sessionManger?.setVideoPlayer(ysVideoPlayer)
        }catch{
            debugPrint("Exception in setting player")
        }
        
        ////////////////////////////////////
        // UI logic for the application only
        switch sessionManager.initialisationState {
        case .notInitialised:
            print("Not initialized url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            break
        case .initialisedNoAnalytics:
            print("No Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            break
        case .initialisedWithAnalytics:
            print("With Analytics url:\(stream.streamSource().absoluteString) itemId:\(stream.streamIdentifier()))")
            
            let sourceConfig = SourceConfiguration()
            sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: stream.streamSource())))
            
            load(sourceConfiguration: sourceConfig);
            break
        default:
            break
        }
    }
}

extension BitmovinYospacePlayer: PlayerListener {
    public func onPlay(_ event: PlayEvent) {
        debugPrint("On Play")
        
        if (sessionInitialized == .notInitialised || sessionInitialized == .initialisedReady){
            print("Firing YoPlaybackStarted Notification")
            sessionInitialized = .initialisedPlaying
            let objects: [Any] = [Int(ysVideoPlayer.currentTime)]
            let keys: [Any] = [kYoPlayheadKey]
            self.notify(objects as [AnyObject], keys: keys as! [String], name: YoPlaybackStartedNotification)
        }
        
    }
    
    public func onPaused(_ event: PausedEvent) {
        print("On Paused")
        print("Firing YoPlaybackPausedNotification")
        let objects: [Any] = [Int(ysVideoPlayer.currentTime)]
        let keys: [Any] = [kYoPlayheadKey]
        self.notify(objects as [AnyObject], keys: keys as! [String], name: YoPlaybackPausedNotification)
        
    }
    
    public func onSeek(_ event: SeekEvent) {
        print("On Seek")

    }
    
    public func onError(_ event: ErrorEvent) {
        print("On Error")

    }
    
    public func onReady(_ event: ReadyEvent) {
        print("On Ready")
        if (sessionInitialized == .notInitialised) {
            print("Firing YoPlaybackReadyNotification")
            let objects = [Any]()
            let keys = [Any]()
            self.notify(objects as [AnyObject], keys: keys as! [String], name: YoPlaybackReadyNotification)
        }

    }
    
    public func onMuted(_ event: MutedEvent) {
        
    }
    
    public func onSeeked(_ event: SeekedEvent) {
        
    }
    
    public func onEvent(_ event: PlayerEvent) {
        
    }
    
    public func onUnmuted(_ event: UnmutedEvent) {
        
    }
    
    public func onMetadata(_ event: MetadataEvent) {
        let meta = YSTimedMetadata()
        for entry: MetadataEntry in event.metadata.entries
        {
            if (entry.metadataType == BMPMetadataType.ID3) {
                let metadata = entry as! AVMetadataItem
                
                guard let key = metadata.key, let data = metadata.dataValue else {
                    continue
                }
                
                switch key.description
                {
                case "YPRG":
                    debugPrint("Programme metadata - ignoring")
                    
                case "YTYP":
                    if let type  = String(data: data, encoding: String.Encoding.utf8)
                    {
                        meta.type = String(type[type.index(type.startIndex, offsetBy: 1)...])
                    }
                    
                case "YSEQ":
                    if let seq = String(data: data, encoding: String.Encoding.utf8)
                    {
                        meta.setSequenceFrom(String(seq[seq.index(seq.startIndex, offsetBy: 1)...]))
                    }
                    
                case "YMID":
                    if let mediaID = String(data: data, encoding: String.Encoding.utf8)
                    {
                        meta.mediaId = String(mediaID[mediaID.index(mediaID.startIndex, offsetBy: 1)...])
                    }
                    
                case "YDUR":
                    if let offset = String(data: data, encoding: String.Encoding.utf8)
                    {
                        if let offset = Double(String(offset[offset.index(offset.startIndex, offsetBy: 1)...]))  {
                            meta.offset = offset
                        }
                    }
                    
                default:
                    break
                }
            }
        }
        if (meta.segmentNumber > 0) && (meta.segmentCount > 0) && (meta.type.count != 0)
        {
            let objects: [Any] = [meta]
            let keys: [Any] = [kYoMetadataKey]
            self.notify(objects as [AnyObject], keys: keys as! [String], name: YoTimedMetadataNotification)
        }
    }
    
    public func onTimeChanged(_ event: TimeChangedEvent) {
        
        
        
    }
    
    public func onPlaybackFinished(_ event: PlaybackFinishedEvent) {
        let objects: [Any] = [Int(self.currentTime), Int(truncating: true)]
        let keys: [Any] = [kYoPlayheadKey, kYoCompletedKey]
        self.notify(objects as [AnyObject], keys: keys as! [String], name: YoPlaybackEndedNotification);
    }
    
    
    func notify(_ objects: [AnyObject], keys: [String], name: String)
    {
        let dictionary = NSDictionary(objects: objects, forKeys: keys as [NSCopying])
        if Thread.isMainThread {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self.ysVideoPlayer, userInfo: dictionary as? [AnyHashable : Any])
        }
        else {
            DispatchQueue.main.async(execute: {() -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: self.ysVideoPlayer, userInfo: dictionary as? [AnyHashable : Any])
            })
        }
    }
    
    
}

