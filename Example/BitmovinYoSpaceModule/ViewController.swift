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

struct Stream {
    var title: String
    var contentUrl: String
    var fairplayLicenseUrl: String?
    var fairplayCertUrl: String?
    var yospaceSourceConfig: YospaceSourceConfiguration?
}

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadUnloadButton: UIButton!
    @IBOutlet weak var streamsTextField: UITextField!
    
    lazy var player: BitmovinYospacePlayer = {
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        configuration.tweaksConfiguration.isNativeHlsParsingEnabled = true

        let player = BitmovinYospacePlayer(
            configuration: configuration,
            yospaceConfiguration: YospaceConfiguration()
        )
        player.add(listener: self)

        return player
    }()
    
    lazy var playerView: PlayerView = {
        let playerView = BMPBitmovinPlayerView(player: player, frame: .zero)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = containerView.bounds
        return playerView
    }()
        
    lazy var streams = [
        Stream(
            title: "Montage FP",
            contentUrl: "https://live-montage-aka-qa.warnermediacdn.com/int/manifest/me-drm-cbcs/master_de.m3u8",
            fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/a229afbf-e1d3-499e-8127-c33cd7231e58",
            fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/a229afbf-e1d3-499e-8127-c33cd7231e58"
        ),
        Stream(
            title: "Bones",
            contentUrl: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_mobile_iphone&context=182883174&nw=42448&prof=48804%3Aturner_ssai&vdur=1800&yo.vp=true&yo.av=2",
            yospaceSourceConfig: .init(yospaceAssetType: .vod)
        )
    ]
    
    var selectedStreamIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.addSubview(playerView)
        createStreamPicker()
    }
    
    func createStreamPicker() {
        let streamPicker = UIPickerView()
        streamPicker.delegate = self
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.closePicker)
        )
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        streamsTextField.inputView = streamPicker
        streamsTextField.inputAccessoryView = toolBar
        streamsTextField.text = streams.first!.title
    }

    @objc func closePicker() {
        view.endEditing(true)
    }

    func destroyPlayer() {
        player.unload()
        player.destroy()
    }

    @IBAction func loadUnloadPressed(_ sender: UIButton) {
        if player.isPlaying {
            player.unload()
        } else {
            loadStream(stream: streams[selectedStreamIndex])
        }
    }

    func loadStream(stream: Stream) {
        guard let streamUrl = URL(string: stream.contentUrl) else { return }
        
        let sourceConfig = SourceConfiguration()
        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        sourceConfig.addSourceItem(item: sourceItem)
        
        if let fairplayLicense = stream.fairplayLicenseUrl, let fairplayCert = stream.fairplayCertUrl {
            let drmConfig = FairplayConfiguration(
                license: URL(string: fairplayLicense),
                certificateURL: URL(string: fairplayCert)!
            )
            prepareDRM(config: drmConfig)
            sourceItem.add(drmConfiguration: drmConfig)
        }
        
        player.load(
            sourceConfiguration: sourceConfig,
            yospaceSourceConfiguration: stream.yospaceSourceConfig
        )
    }
    
    func prepareDRM(config: FairplayConfiguration) {
        config.prepareCertificate = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: "")) else {
                    return data
            }
            return certResult
        }
        config.prepareContentId = { (contentId: String) -> String in
            let prepared = contentId.replacingOccurrences(of: "skd://", with: "")
            let components: [String] = prepared.components(separatedBy: "/")
            return components[2]
        }
        config.prepareMessage = { (spcData: Data, assetID: String) -> Data in
            return spcData
        }
        config.prepareLicense = { (ckcData: Data) -> Data in
            guard let ckcString = String(data: ckcData, encoding: .utf8),
                let ckcResult = Data(base64Encoded: ckcString.replacingOccurrences(of: "\"", with: "")) else {
                    return ckcData
            }
            return ckcResult
        }
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

extension ViewController: PlayerListener {
    func onSourceLoaded(_ event: SourceLoadedEvent) {
        loadUnloadButton.setTitle("Unload", for: .normal)
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        loadUnloadButton.setTitle("Load", for: .normal)
    }
}
