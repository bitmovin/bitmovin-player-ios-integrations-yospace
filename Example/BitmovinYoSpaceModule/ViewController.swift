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
    var drmHeader: String?
    var yospaceSourceConfig: YospaceSourceConfiguration?
}

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadUnloadButton: UIButton!
    @IBOutlet weak var streamsTextField: UITextField!
    
    lazy var player: BitmovinYospacePlayer = {
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
        player.add(listener: self)
        player.add(integrationListener: self)

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
            title: "Metadata fix",
            contentUrl: "https://csm-e-cetuusexaws208j8-6lppcszb2ede.bln1.yospace.com/csm/extlive/turner01,timed-tbseast-cbcs.m3u8?yo.pst=true&yo.av=2&yo.pdt=true&yo.t.jt=1000&yo.me=true&yo.ap=https://vod-media-aka.warnermediacdn.com&yo.po=-4&yo.up=https://live-media-aka.warnermediacdn.com&yo.asd=true&yo.pdt=true&yo.dr=true&_fw_ae=53da17a30bd0d3c946a41c86cb5873f1&_fw_ar=1&afid=180483280&conf_csid=tbs.com_desktop_live_east&nw=42448&prof=48804:tbs_ios_live",
            fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/de4c1d30-ac22-4669-8824-19ba9a1dc128",
            fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/de4c1d30-ac22-4669-8824-19ba9a1dc128",
            drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ._Y3KGenESJE86od8bU5R0w.QxjBP2BQ9LPDwHKs839wikSGAzZXoSivLVMC_z4o_ONF2PlbKZQ0xTF46m7mNBj2Ps7q53tT_cmNqvJV8SXwoeVDUwpUOt5aiRsVGBDX8760SPwBpEKqVM9N5OFZOPIi8jTuVmh04cfVLzLOdvesEa_00A4OmIJ1jFryDX_qobdLmmiR8ILvAiKHOutTQSI00sRdE86Z4xJsmfAY3yeShWQiFJVRuKyMTDuAwfzCWOOcTqYwPCYiAyt9w_woO8OdiygHeQ.1BRXjxq4OHcxsgjbqCbt9g"
        ),
        // Note - this stream wasn't getting ads; TBD which kvp was causing that
        Stream(
            title: "MML live",
            contentUrl: "https://live-manifests-att-qa.warnermediacdn.com/csmp/cmaf/live/2018448/mml000-cbcs/master_fp_ph.m3u8?_fw_ae=%5Bfw_ae%5D&_fw_ar=%5B_fw_ar%5D&_fw_did=%5B_fw_did%5D&_fw_is_lat=%5B_fw_is_lat%5D&_fw_nielsen_app_id=P923E8EA9-9B1B-4F15-A180-F5A4FD01FE38&_fw_us_privacy=%5B_fw_us_privacy%5D&_fw_vcid2=%5B_fw_vcid2%5D&afid=180494037&caid=hylda_beta_test_asset&conf_csid=ncaa.com_mml_iphone&nw=42448&playername=top-2.1.2&prct=text%252Fhtml_doc_lit_mobile%252Ctext%252Fhtml_doc_ref&prof=48804%3Amml_ios_live&yo.asd=true&yo.dnt=false&yo.pst=true",
            fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug",
            yospaceSourceConfig: .init(yospaceAssetType: .linear)
        ),
        Stream(
            title: "MML live - Safari",
            contentUrl: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2018448/mml000-cbcs/master_fp_de.m3u8?_fw_ae=&_fw_ar=&_fw_did=&_fw_is_lat=&_fw_nielsen_app_id=P923E8EA9-9B1B-4F15-A180-F5A4FD01FE38&_fw_us_privacy=&_fw_vcid2=&afid=180494037&caid=hylda_beta_test_asset&conf_csid=ncaa.com_mml_iphone&nw=42448&playername=top-2.1.2&prct=text%2Fhtml_doc_lit_mobile%2Ctext%2Fhtml_doc_ref&prof=48804:mml_ios_live&yo.asd=true&yo.dnt=false&yo.pst=true&yo.dr=true&yo.ad=true",
            fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug",
            yospaceSourceConfig: .init(yospaceAssetType: .linear)
        ),
        Stream(
            title: "MML live - no ads",
            contentUrl: "https://mml-live-media-aka-qa.warnermediacdn.com/cmaf/live/2018448/mml000-cbcs/master_fp_de.m3u8",
            fairplayLicenseUrl: "https://fairplay.license.istreamplanet.com/api/license/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            fairplayCertUrl: "https://fairplay.license.istreamplanet.com/api/AppCert/e892c6cc-2f78-4a9f-beae-556a36167bb1",
            drmHeader: "eyJ2ZXIiOjEsInR5cCI6IkpXVCIsImVuYyI6IkExMjhHQ00ifQ.hcU9wETKG96GJKUW5Vb7mQ.JeEpL1BSu85sEOvLi72fLAibF58_uk01pdwbghvtzfTnh4HG88mB7GHEqTYz--kWgBeL0gfIapqENku2P8eSOAeDWculu85dOdHDGbZKZS_m4Ut_4B18cE362R_U6rVz1J9uDPL4TCvniO6I-pv8xwHdIdYxmkk4R9sz5mvASlWtqSa4EwNp5cSrmPXxFHvRLdNmxzA2WNxzqI-S3t1KXxgy5wBQj2nxCVcJrrRFgFoIiZJgJqXyaA.5CeKW7zibMN4iqCqGkZcug"
        ),
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
    
//    lazy var playheadNormalizer = PlayheadNormalizer(player: player)
    
    var selectedStreamIndex = 2
    
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
        streamsTextField.text = streams[selectedStreamIndex].title
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
        print("Loading \(streamUrl)")
        
        let sourceConfig = SourceConfiguration()
        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        sourceConfig.addSourceItem(item: sourceItem)
        
        if let fairplayLicense = stream.fairplayLicenseUrl, let fairplayCert = stream.fairplayCertUrl {
            let drmConfig = FairplayConfiguration(
                license: URL(string: fairplayLicense),
                certificateURL: URL(string: fairplayCert)!
            )
            
            if let drmHeader = stream.drmHeader {
                print("Setting DRM header")
                drmConfig.licenseRequestHeaders = ["x-isp-token": drmHeader]
            }

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
    
    var timeChangedFired = false
    var prevTimeChanged = 0.0
    func detectTimeJump(time: Double) {
        if (!timeChangedFired) {
            prevTimeChanged = time
            timeChangedFired = true
            return
        }
        
        let delta = time - prevTimeChanged
        if (delta > 2.0 || delta < -0.5) {
            print("[raw] Time jump detected: \(delta) [\(time), \(prevTimeChanged)] ❌")
        } else {
//            print("[raw] Time update: \(time) | \(delta)")
        }
        prevTimeChanged = time
    }
    
//    let playheadNormalizer: PlayheadNormalizer = PlayheadNormalizer()
    func testNormalizeTime(time: Double) {
//        let newTime = playheadNormalizer.normalize(time: time)
//        print("[normalized] Time update: \(time) | \(newTime)")
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

extension ViewController: IntegrationListener {
    func onPlayheadNormalizingStarted() {
        print("cdg - onPlayheadNormalizingStarted")
    }
    
    func onPlayheadNormalizingFinished() {
        print("cdg - onPlayheadNormalizingFinished")
    }
}

extension ViewController: PlayerListener {
    func onSourceLoaded(_ event: SourceLoadedEvent) {
        loadUnloadButton.setTitle("Unload", for: .normal)
    }

    func onTimeChanged(_ event: TimeChangedEvent) {
        
        
        // If it's not a yospace stream, use the external normalizer
        if streams[selectedStreamIndex].yospaceSourceConfig == nil {
            detectTimeJump(time: event.currentTime)
            testNormalizeTime(time: event.currentTime)
        } else {
            detectTimeJump(time: player.currentTimeWithAds())
        }
    }
    
    func onMetadataParsed(_ event: MetadataParsedEvent) {
        print("c.extra - metadataParsed - \(event.metadataType), \(event.metadata.entries)")
    }
    
    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        loadUnloadButton.setTitle("Load", for: .normal)
    }
 
    func onError(_ event: ErrorEvent) {
        print("[onError] \(event.message)")
    }
}
