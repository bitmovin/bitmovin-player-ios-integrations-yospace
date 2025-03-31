//
//  ViewController.swift
//  BitmovinYospaceModule_Example_tvOS
//
//  Created by Bitmovin on 11/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import BitmovinPlayer
import BitmovinYospaceModule
import UIKit

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
        let playerConfig = PlayerConfig()
        playerConfig.key = "Your License Key"
        playerConfig.playbackConfig.isAutoplayEnabled = true

        let player = BitmovinYospacePlayer(
            playerConfig: playerConfig,
            yospaceConfig: .init()
        )

        player.add(listener: self)

        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        playerContainer.addSubview(playerView)
    }

    @IBAction func unloadButtonClicked(sender _: UIButton) {
        player.unload()
    }

    @IBAction func liveButtonClicked(sender _: UIButton) {
        guard let streamUrl = URL(string: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2000073/cnn-clear-novpaid/master.m3u8") else {
            return
        }

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        let yospaceSourceConfig = YospaceSourceConfig(yospaceAssetType: .linear)

        player.load(sourceConfig: sourceConfig, yospaceSourceConfig: yospaceSourceConfig)
    }

    @IBAction func vodButtonClicked(sender _: UIButton) {
        guard let streamUrl = URL(string: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_mobile_iphone&context=182883174&nw=42448&prof=48804%3Aturner_ssai&vdur=1800&yo.vp=true&yo.av=2") else {
            return
        }

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)
        let yospaceSourceConfig = YospaceSourceConfig(yospaceAssetType: .vod)

        player.load(sourceConfig: sourceConfig, yospaceSourceConfig: yospaceSourceConfig)
    }
}

extension ViewController: PlayerListener {
    func onTimeChanged(_: TimeChangedEvent, player _: Player) {
        adLabel.text = "Ad: \(player.isAd) time=\(Double(round(10 * player.currentTime) / 10))"
    }
}
