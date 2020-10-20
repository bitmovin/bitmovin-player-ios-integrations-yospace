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
    @IBOutlet var playerContainer: UIView!
    @IBOutlet var unloadButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var vodButton: UIButton!
    @IBOutlet var adLabel: UILabel!
    
    lazy var playerView: PlayerView = {
        let playerView = PlayerView(player: player, frame: .zero)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = playerContainer.bounds
        return playerView
    }()
    
    lazy var player: BitmovinYospacePlayer = {
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true

        let player = BitmovinYospacePlayer(
            configuration: configuration,
            yospaceConfiguration: .init()
        )

        player.add(listener: self)
        
        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        playerContainer.addSubview(playerView)
    }
    
    @IBAction func unloadButtonClicked(sender: UIButton) {
        player.unload()
    }

    @IBAction func liveButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2000073/cnn-clear-novpaid/master.m3u8") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)

        player.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    @IBAction func vodButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_mobile_iphone&context=182883174&nw=42448&prof=48804%3Aturner_ssai&vdur=1800&yo.vp=true&yo.av=2") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .vod)

        player.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
}

extension ViewController: PlayerListener {
    func onTimeChanged(_ event: TimeChangedEvent) {
        adLabel.text = "Ad: \(player.isAd) time=\(Double(round(10*player.currentTime)/10))"
    }
}
