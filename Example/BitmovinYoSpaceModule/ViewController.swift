//
//  ViewController.swift
//  BitmovinYoSpaceModule
//
//  Created by Cory Zachman on 10/16/2018.
//  Copyright (c) 2018 Cory Zachman. All rights reserved.
//

import UIKit
import BitmovinYoSpaceModule
import BitmovinPlayer

class ViewController: UIViewController {
    var bitmovinYoSpacePlayer: BitmovinYoSpacePlayer?;
    @IBOutlet var playerView: UIView!
    @IBOutlet var unloadButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var vodButton: UIButton!
    @IBOutlet var startOverButton: UIButton!
    @IBOutlet var clickButton: UIButton!
    
    override func viewDidLoad() {
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        bitmovinYoSpacePlayer = BitmovinYoSpacePlayer(configuration: configuration)
        
        guard let player = bitmovinYoSpacePlayer else {
            return
        }
        
        super.viewDidLoad()
        
        self.playerView.backgroundColor = .black
            // Create player view and pass the player instance to it
        let playerBoundary = BMPBitmovinPlayerView(player:player, frame: .zero)
            
        playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerBoundary.frame = playerView.bounds
            
        playerView.addSubview(playerBoundary)
        playerView.bringSubviewToFront(playerBoundary)
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
        let config = YospaceSourceConfiguration(yoSpaceAssetType: .linear)
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config);
    }
    
    @IBAction func vodButtonClicked(sender: UIButton) {

        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/csm/access/152902489/ZmY5ZDkzOWY1ZWE0NTFmY2IzYmZkZTcxYjdjNzM0ZmQvbWFzdGVyX3VucHZfdHYubTN1OA==") else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yoSpaceAssetType: .vod)
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config);
    }
    
    @IBAction func startOverButtonClicked(sender: UIButton) {
        guard let streamUrl = URL(string: "https://vodp-e-turner-eb.tls1.yospace.com/access/event/latest/110611066?promo=130805986") else {
            return
        }
        
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yoSpaceAssetType: .linearStartOver)
        
        bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config);
    }
    
    @IBAction func clickButtonClicked(sender: UIButton) {
        
    }
    

}

