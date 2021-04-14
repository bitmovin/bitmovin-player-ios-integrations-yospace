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

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadUnloadButton: UIButton!
    @IBOutlet weak var streamsTextField: UITextField!
    
    var player: (player: BitmovinYospacePlayer, view: PlayerView)!
    var selectedStreamIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        initializePlayer()
        configureStreamPicker()
    }
    
    func initializePlayer() {
        let playerConfig = PlayerConfiguration()
        playerConfig.playbackConfiguration.isAutoplayEnabled = true
        playerConfig.tweaksConfiguration.isNativeHlsParsingEnabled = true

        let yospaceConfig = YospaceConfiguration(debug: true)
        
        let bitmovinYospaceConfig = BitmovinYospaceConfiguration(
            playerConfiguration: playerConfig,
            yospaceConfiguration: yospaceConfig,
            enablePlayheadNormalization: true,
            debug: true
        )
        
        let player = BitmovinYospacePlayer(configuration: bitmovinYospaceConfig)
        let playerView = BMPBitmovinPlayerView(player: player, frame: containerView.bounds)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(playerView)
        containerView.bringSubviewToFront(playerView)
    
        self.player = (player, playerView)
    }
    
    func configureStreamPicker() {
        let streamPicker = UIPickerView()
        streamPicker.delegate = self
        streamsTextField.inputView = streamPicker
        streamsTextField.text = streams[selectedStreamIndex].title
    }
    
    @IBAction func didTapPlaybackButton(_ sender: UIButton) {
        if player.player.isPlaying {
            player.player.unload()
        } else {
            load(streams[selectedStreamIndex])
        }
        hideStreamPicker()
    }
    
    func hideStreamPicker() {
        view.endEditing(true)
    }

    func load(_ stream: Stream) {
        guard let streamUrl = URL(string: stream.contentUrl) else { return }

        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        
        if let fairplayLicense = stream.fairplayLicenseUrl, let fairplayCert = stream.fairplayCertUrl {
            let drmConfig = FairplayConfiguration(license: URL(string: fairplayLicense), certificateURL: URL(string: fairplayCert)!)
            
            if let drmHeader = stream.drmHeader {
                drmConfig.licenseRequestHeaders = ["x-isp-token": drmHeader]
            }

            sourceItem.add(drmConfiguration: drmConfig.prepared())
        }
        
        player.player.load(sourceItem: sourceItem, yospaceSourceConfiguration: stream.yospaceSourceConfig)
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return streams.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return streams[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStreamIndex = row
        streamsTextField.text = streams[row].title
    }
}

extension FairplayConfiguration {
    func prepared() -> FairplayConfiguration {
        prepareCertificate = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: "")) else {
                    return data
            }
            return certResult
        }
        prepareContentId = { (contentId: String) -> String in
            let prepared = contentId.replacingOccurrences(of: "skd://", with: "")
            let components: [String] = prepared.components(separatedBy: "/")
            return components[2]
        }
        prepareMessage = { (spcData: Data, assetID: String) -> Data in
            return spcData
        }
        prepareLicense = { (ckcData: Data) -> Data in
            guard let ckcString = String(data: ckcData, encoding: .utf8),
                let ckcResult = Data(base64Encoded: ckcString.replacingOccurrences(of: "\"", with: "")) else {
                    return ckcData
            }
            return ckcResult
        }
        return self
    }
}
