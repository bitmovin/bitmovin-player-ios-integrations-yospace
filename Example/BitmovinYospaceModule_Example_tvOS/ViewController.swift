//
//  ViewController.swift
//  BitmovinYospaceModule_Example_tvOS
//
//  Created by Bitmovin on 11/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinYospaceModule

class ViewController: UIViewController {
    var bitmovinYospacePlayer: BitmovinYospacePlayer?
    @IBOutlet var playerView: UIView!
    @IBOutlet var unloadButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var vodButton: UIButton!
    @IBOutlet var startOverButton: UIButton!
    @IBOutlet var adLabel: UILabel!

    var clickUrl: URL?
    var policy: BitmovinExamplePolicy = BitmovinExamplePolicy()

    override func viewDidLoad() {
        // Create a Player Configuration
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true

        // Create a YospaceConfiguration
        let yospaceConfiguration = YospaceConfiguration(debug: true, userAgent: "Custom User Agent", timeout: 5000)

        //Create a BitmovinYospacePlayer
        bitmovinYospacePlayer = BitmovinYospacePlayer(configuration: configuration, yospaceConfiguration: yospaceConfiguration)

        //Add your listeners
        bitmovinYospacePlayer?.add(listener: self)
        bitmovinYospacePlayer?.add(yospaceListener: self)

        bitmovinYospacePlayer?.playerPolicy = policy

        guard let player = bitmovinYospacePlayer else {
            return
        }

        super.viewDidLoad()

        self.playerView.backgroundColor = .black
        // Create player view and pass the player instance to it
        let playerBoundary = BMPBitmovinPlayerView(player: player, frame: .zero)

        playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundary.frame = playerView.bounds

        playerView.addSubview(playerBoundary)
        playerView.bringSubviewToFront(liveButton)
        playerView.bringSubviewToFront(vodButton)
        playerView.bringSubviewToFront(startOverButton)
        playerView.bringSubviewToFront(unloadButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func unloadButtonClicked(sender: UIButton) {
        self.bitmovinYospacePlayer?.unload()
    }

    @IBAction func liveButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: cnnUrl) else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func vodButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: bonesVodUrl) else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .vod)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func startOverButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: startOverUrl) else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .nonLinearStartOver)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
}

extension ViewController: PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent) {
        NSLog("Ad Started -  \(bitmovinYospacePlayer?.getActiveAd()?.debugDescription ?? "")")
        clickUrl = event.clickThroughUrl
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("Ad Finished \(bitmovinYospacePlayer?.getActiveAd()?.debugDescription ?? "")")
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        NSLog("Ad Break Started")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("Ad Break Finished -  \(bitmovinYospacePlayer?.getActiveAdBreak()?.debugDescription ?? "")")

    }

    public func onAdClicked(_ event: AdClickedEvent) {
        NSLog("Ad Clicked")
    }

    public func onTimeChanged(_ event: TimeChangedEvent) {
        guard let player = bitmovinYospacePlayer else {
            return
        }
        self.adLabel.text = "Ad: \(player.isAd) time=\(Double(round(10*player.currentTime)/10))"
    }

    public func onError(_ event: ErrorEvent) {
        NSLog("On Error: \(event.code) - \(event.message)")
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

    }

    public func onTrueXAdFree() {

    }
}
