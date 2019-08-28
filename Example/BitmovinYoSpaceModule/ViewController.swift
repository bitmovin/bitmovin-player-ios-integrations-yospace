//
//  ViewController.swift
//  BitmovinYoSpaceModule
//
//  Created by Bitmovin on 10/16/2018.
//  Copyright (c) 2018 Cory Zachman. All rights reserved.
//

import UIKit
import BitmovinYospaceModule
import BitmovinPlayer
import Toast_Swift

class ViewController: UIViewController {
    var bitmovinYospacePlayer: BitmovinYospacePlayer?
    @IBOutlet var playerView: UIView!
    @IBOutlet var unloadButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var vodButton: UIButton!
    @IBOutlet var startOverButton: UIButton!
    @IBOutlet var clickButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var assetType: UISegmentedControl!
    @IBOutlet var adLabel: UILabel!
    
    var bitmovinPlayerView: PlayerView?
    var clickUrl: URL?

    override func viewDidLoad() {
        clickButton.isEnabled = false
        createPlayer()
    }

    func createPlayer() {
        // Create a Player Configuration
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        configuration.playbackConfiguration.isMuted = true
        
        // Create a YospaceConfiguration
        let yospaceConfiguration = YospaceConfiguration(debug: false, timeout: 5000)
        
        //Create a BitmovinYospacePlayer
        bitmovinYospacePlayer = BitmovinYospacePlayer(configuration: configuration, yospaceConfiguration: yospaceConfiguration)

        //Add your listeners
        bitmovinYospacePlayer?.add(listener: self)
        bitmovinYospacePlayer?.add(yospaceListener: self)

        let policy: BitmovinExamplePolicy = BitmovinExamplePolicy()
        bitmovinYospacePlayer?.playerPolicy = policy

        guard let player = bitmovinYospacePlayer else {
            return
        }
        
        self.playerView.backgroundColor = .black

        if bitmovinPlayerView == nil {
            // Create player view and pass the player instance to it
            bitmovinPlayerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            guard let view = bitmovinPlayerView else {
                return
            }

            // Size the player view
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = playerView.bounds
            playerView.addSubview(view)
            playerView.bringSubviewToFront(view)

        } else {
            bitmovinPlayerView?.player = bitmovinYospacePlayer
        }

    }

    func destroyPlayer() {
        bitmovinYospacePlayer?.unload()
        bitmovinYospacePlayer?.destroy()
        bitmovinYospacePlayer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func unloadButtonClicked(sender: UIButton) {
        self.bitmovinYospacePlayer?.unload()
    }

    @IBAction func reloadButtonClicked(sender: UIButton) {
        destroyPlayer()
        createPlayer()
    }

    @IBAction func liveButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://ssai.cdn.turner.com/csmp/cmaf/live/2000073/tbse-clear-novpaid/master.m3u8?yo.aas=true&yo.av=2&yo.ch=true&yo.ac=true&yo.po=-4&yo.ad&yo.dr=true") else {
            return
        }
        
//        guard let streamUrl = URL(string: "http://csm-e.cds1.yospace.com/csm/extlive/yospace02,hlssample.m3u8?yo.br=false&yo.ac=true") else {
//            return
//        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
    
    @IBAction func customButtonClicked(sender: UIButton) {
        let yospaceSourceConfiguration: YospaceSourceConfiguration?
        guard let url = textField.text else {
            return
        }
        
        guard let streamUrl = URL(string: url) else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        
        if (assetType.selectedSegmentIndex == 0) {
            yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .linear)
        }else {
            yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .vod)
        }
        
        guard let conf = yospaceSourceConfiguration else {
            return
        }
        
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: conf)
    }

    @IBAction func vodButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://csm-e-stg.tls1.yospace.com/csm/access/525947592/cWEvY21hZl9hZHZhbmNlZF9mbXA0X2Zyb21faW50ZXIvcHJvZ19zZWcvbXdjX0NBUkUxMDA5MjYxNzAwMDE4ODUyL2NsZWFyLzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjL21hc3Rlcl9jbF9ub19pZnJhbWUubTN1OA==?yo.av=2") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .vod)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func startOverButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://csm-e-turnerstg-5p30c9t6lfad.tls1.yospace.com/csm/access/525947592/cWEvY21hZl9hZHZhbmNlZF9mbXA0X2Zyb21faW50ZXIvZnVsbF9sZW4vbXdjX0NBUkUxMDA5MjYxNzAwMDE4ODUyL2NiY3MvM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MwMDAwMDJiMC9tYXN0ZXJfZnAubTN1OAo=?yo.av=2&yo.ad=true") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let drmConfiguration = FairplayConfiguration(license: URL(string: "https://fairplay.license.istreamplanet.com/api/license/a229afbf-e1d3-499e-8127-c33cd7231e58"), certificateURL: URL(string: "https://fairplay.license.istreamplanet.com/api/AppCert/a229afbf-e1d3-499e-8127-c33cd7231e58")!)
        
        drmConfiguration.prepareCertificate = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: "")) else {
                    return data
            }
            return certResult
        }
        drmConfiguration.prepareContentId = { (contentId: String) -> String in
            let prepared = contentId.replacingOccurrences(of: "skd://", with: "")
            let components : [String] = prepared.components(separatedBy: "/")
            return components[2]
        }
        drmConfiguration.prepareMessage = { (spcData: Data, assetID: String) -> Data in
            return spcData
        }
        drmConfiguration.prepareLicense = { (ckcData: Data) -> Data in
            guard let ckcString = String(data: ckcData, encoding: .utf8),
                let ckcResult = Data(base64Encoded: ckcString.replacingOccurrences(of: "\"", with: "")) else {
                    return ckcData
            }
            return ckcResult
        }
        
        sourceConfig.firstSourceItem?.add(drmConfiguration: drmConfiguration)
        let config = YospaceSourceConfiguration(yospaceAssetType: .nonLinearStartOver)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
    
    @IBAction func trueXButtonClicked(sender: UIButton){
        guard let streamUrl = URL(string: "https://csm-e-stg.tls1.yospace.com/csm/access/525943851/cWEvY21hZl9hZHZhbmNlZF9mbXA0X2Zyb21faW50ZXIvcHJvZ19zZWcvbXdjX0NBUkUxMDA5MjYxNzAwMDE4ODUyL2NsZWFyLzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjM2MzYzNjL21hc3Rlcl9jbF9ub19pZnJhbWUubTN1OA==?yo.av=2") else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .vod)
        
        // Create a TruexConfiguration
        let truexConfiguration = TruexConfiguration(view: playerView, userId: "turner_bm_ys_tester_001", vastConfigUrl: "qa-get.truex.com/07d5fe7cc7f9b5ab86112433cf0a83b6fb41b092/vast/config?asnw=&cpx_url=&dimension_2=0&flag=%2Bamcb%2Bemcr%2Bslcb%2Bvicb%2Baeti-exvt&fw_key_values=&metr=0&network_user_id=turner_bm_ys_tester_001&prof=g_as3_truex&ptgt=a&pvrn=&resp=vmap1&slid=fw_truex&ssnw=&stream_position=midroll&vdur=&vprn=")
        
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config, truexConfiguration: truexConfiguration)

    }

    @IBAction func clickButtonClicked(sender: UIButton) {
        guard let url = clickUrl else {
            return
        }
        bitmovinYospacePlayer?.clickThroughPressed()
        UIApplication.shared.openURL(url)

    }
    
    @IBAction func skipAd(sender: UIButton) {
        bitmovinYospacePlayer?.skipAd()
    }

}

extension ViewController: PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent) {
        NSLog("Ad Started \(bitmovinYospacePlayer?.getActiveAd()?.debugDescription)")
        self.adLabel.text = "Ad: true"
        clickButton.isEnabled = true
        clickUrl = event.clickThroughUrl
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("Ad Finished \(bitmovinYospacePlayer?.getActiveAd()?.debugDescription)")
        self.adLabel.text = "Ad: false"
        clickButton.isEnabled = false
        clickUrl = nil
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        NSLog("Ad Break Started \(bitmovinYospacePlayer?.getActiveAdBreak()?.debugDescription)")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("Ad Break Finished \(bitmovinYospacePlayer?.getActiveAdBreak()?.debugDescription)")
        
    }

    public func onAdClicked(_ event: AdClickedEvent) {
        NSLog("Ad Clicked")
        self.view.makeToast("Ad Clicked")
    }
    
    public func onDurationChanged(_ event: DurationChangedEvent) {
        NSLog("On Duration Changed: \(event.duration)")
    }
    
    public func onError(_ event: ErrorEvent) {
        NSLog("On Error: \(event.code)")
    }
    
    public func onTimeChanged(_ event: TimeChangedEvent) {
//        NSLog("On Time Changed - EventTime: \(event.currentTime) Duration: \(bitmovinYospacePlayer!.duration) TimeShift: \(bitmovinYospacePlayer!.timeShift) MaxTimeShift: \(bitmovinYospacePlayer!.maxTimeShift) isLive: \(bitmovinYospacePlayer!.isLive)")
    }
}

extension ViewController: YospaceListener {
    public func onYospaceError(event: ErrorEvent) {
        let message = "Error: \(event.code) -  \(event.message)"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func onTimelineChanged(event: AdTimelineChangedEvent) {
        NSLog("Timeline Changed: \(event.timeline.debugDescription)")
    }
}
