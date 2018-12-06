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
        
        // Create a YospaceConfiguration
        let yospaceConfiguration = YospaceConfiguration(debug: false, userAgent: "Custom User Agent", timeout: 5000)

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
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unloadButtonClicked(sender: UIButton) {
        self.bitmovinYospacePlayer?.unload()
    }

    @IBAction func reloadButtonClicked(sender: UIButton) {
        destroyPlayer()
        createPlayer()
    }

    @IBAction func liveButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "http://csm-e-ces1eurxaws101j8-6x78eoil2agd.cds1.yospace.com/csm/extlive/yospace02,hlssample.m3u8?yo.br=true&yo.ac=true") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        sourceConfig.addSourceItem(item: sourceItem)
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func vodButtonClicked(sender: UIButton) {
//        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/csm/access/152902489/ZmY5ZDkzOWY1ZWE0NTFmY2IzYmZkZTcxYjdjNzM0ZmQvbWFzdGVyX3VucHZfdHYubTN1OA==") else {
//            return
//        }

        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/csm/access/152908799/ZmY5ZDkzOWY1ZWE0NTFmY2IzYmZkZTcxYjdjNzM0ZmQvbWFzdGVyX3VucHZfdHYubTN1OA==") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .vod)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func startOverButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/access/event/latest/110611066?promo=130805986") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .nonLinearStartOver)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
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
        NSLog("Ad Started")
        self.view.makeToast("Ad Started")
        clickButton.isEnabled = true
        clickUrl = event.clickThroughUrl
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("Ad Finished")
        self.view.makeToast("Ad Finished")

        clickButton.isEnabled = false
        clickUrl = nil
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        NSLog("Ad Break Started")
        self.view.makeToast("Ad Break Started")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("Ad Break Finished")
        self.view.makeToast("Ad Break Finished")
    }

    public func onAdClicked(_ event: AdClickedEvent) {
        NSLog("Ad Clicked")
        self.view.makeToast("Ad Clicked")
    }
    
    public func onDurationChanged(_ event: DurationChangedEvent) {
        NSLog("On Duration Changed: \(event.duration)")
    }
    
    public func onTimeChanged(_ event: TimeChangedEvent) {
        NSLog("On Time Changed - EventTime: \(event.currentTime) Duration: \(bitmovinYospacePlayer!.duration) TimeShift: \(bitmovinYospacePlayer!.timeShift) MaxTimeShift: \(bitmovinYospacePlayer!.maxTimeShift) isLive: \(bitmovinYospacePlayer!.isLive)")
    }
}

extension ViewController: YospaceListener {
    public func onYospaceError(event: ErrorEvent) {
        let message = "Error: \(event.code) -  \(event.message)"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
}
