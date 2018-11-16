//
//  ViewController.swift
//  BitmovinYospaceModule_Example_tvOS
//
//  Created by Cory Zachman on 11/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import BitmovinPlayer
import BitmovinYospaceModule

class ViewController: UIViewController {
    var bitmovinYoSpacePlayer: BitmovinYospacePlayer?
    @IBOutlet var playerView: UIView!
    @IBOutlet var unloadButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var vodButton: UIButton!
    @IBOutlet var startOverButton: UIButton!
    var clickUrl: URL?
    
    override func viewDidLoad() {
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        bitmovinYoSpacePlayer = BitmovinYospacePlayer(configuration: configuration)
        bitmovinYoSpacePlayer?.add(listener: self)
        bitmovinYoSpacePlayer?.add(yospaceListener: self)
        
        guard let player = bitmovinYoSpacePlayer else {
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

        vodButtonClicked(sender: vodButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unloadButtonClicked(sender: UIButton) {
        self.bitmovinYoSpacePlayer?.unload()
    }
    
    @IBAction func liveButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "http://csm-e-ces1eurxaws101j8-6x78eoil2agd.cds1.yospace.com/csm/extlive/yospace02,hlssample.m3u8?yo.br=true&yo.ac=true") else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
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
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
    
    @IBAction func startOverButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/access/event/latest/110611066?promo=130805986") else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linearStartOver)
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }
    
    @IBAction func clickButtonClicked(sender: UIButton) {
        guard let url = clickUrl else {
            return
        }
        bitmovinYoSpacePlayer?.clickThroughPressed()
        UIApplication.shared.openURL(url)
        
    }
    
}

extension ViewController: PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent) {
        NSLog("Ad Started")
        clickUrl = event.clickThroughUrl
    }
    
    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("Ad Finished")
        clickUrl = nil
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        NSLog("Ad Break Started")
    }
    
    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        NSLog("Ad Break Finished")
    }
    
    public func onAdClicked(_ event: AdClickedEvent) {
        NSLog("Ad Clicked")        
    }
}

extension ViewController: YospaceListener {
    public func onYospaceError(event: ErrorEvent){
        let alert = UIAlertController(title: "Alert", message: "Error: \(event.code) -  \(event.message)" , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
}
