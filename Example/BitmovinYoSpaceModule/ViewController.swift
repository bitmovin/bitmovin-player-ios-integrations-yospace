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
    @IBOutlet weak var adBreakCounterLabel: UILabel!
    @IBOutlet weak var adBreakFinishCountLabel: UILabel!
    @IBOutlet weak var adFinishCountLabel: UILabel!
    @IBOutlet weak var adStartCountLabel: UILabel!
    @IBOutlet weak var adBreakStartCountLabel: UILabel!
    @IBOutlet weak var bufferLabel: UILabel!
    @IBOutlet weak var streamsTextField: UITextField!
    @IBOutlet weak var seekTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var bitmovinYospacePlayer: BitmovinYospacePlayer?
    var bitmovinPlayerView: PlayerView?

    private var listItems: [ListItem] = []
    private let streamNames: [String] = ["Live CNN", "TBSE-WV", "VoD", "TrueX", "Non-Yospace"]
    private var selectedStreamIndex = 0
    private var adBreakStartCount = 0 {
        didSet {
            adBreakStartCountLabel.text = String(format: "ABS: %d", adBreakStartCount)
        }
    }
    private var adStartCount = 0 {
        didSet {
            adStartCountLabel.text = String(format: "AS: %d", adStartCount)
        }
    }
    private var adFinishCount = 0 {
        didSet {
            adFinishCountLabel.text = String(format: "AF: %d", adFinishCount)
        }
    }
    private var adBreakFinishCount = 0 {
        didSet {
            adBreakFinishCountLabel.text = String(format: "ABF: %d", adBreakFinishCount)
        }
    }

    override func viewDidLoad() {
        createPlayer()
        createStreamPicker()
    }

    func createPlayer() {
        // Create a Player Configuration
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        configuration.playbackConfiguration.isMuted = true

        // Create a YospaceConfiguration
        let yospaceConfiguration = YospaceConfiguration(debug: true, timeout: 5000)

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

        self.containerView.backgroundColor = .black

        if bitmovinPlayerView == nil {
            // Create player view and pass the player instance to it
            bitmovinPlayerView = BMPBitmovinPlayerView(player: player, frame: .zero)

            guard let view = bitmovinPlayerView else {
                return
            }

            // Size the player view
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.frame = containerView.bounds
            containerView.addSubview(view)
            containerView.bringSubviewToFront(view)

        } else {
            bitmovinPlayerView?.player = bitmovinYospacePlayer
        }

    }

    private func createStreamPicker() {
        let streamPicker = UIPickerView()
        streamPicker.delegate = self
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.closePicker))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        streamsTextField.inputView = streamPicker
        streamsTextField.inputAccessoryView = toolBar
        streamsTextField.text = streamNames.first
    }

    @objc private func closePicker() {
        view.endEditing(true)
    }

    func destroyPlayer() {
        bitmovinYospacePlayer?.unload()
        bitmovinYospacePlayer?.destroy()
        bitmovinYospacePlayer = nil
    }

    @IBAction func loadUnloadPressed(_ sender: UIButton) {
        if loadUnloadButton.title(for: .normal) == "Load" {
            switch selectedStreamIndex {
            case 0:
                loadLiveCNN()
            case 1:
                loadLiveTBSE()
            case 2:
                loadVod()
            case 3:
                loadTruex()
            case 4, _:
                loadNonYospace()
            }
        } else {
            bitmovinYospacePlayer?.unload()
        }
        resetUI()
    }

    @IBAction func seekPressed(_ sender: UIButton) {
       if let seekInput: String = seekTextField.text, let seekTime = TimeInterval(seekInput) {
           bitmovinYospacePlayer?.seek(time: seekTime)
       }
    }

    private func loadLiveCNN() {
        guard let streamUrl = URL(string: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2000073/cnn-clear-novpaid/master.m3u8?yo.dr=true&yo.av=2&yo.pdt=true&yo.pst=true") else {
            return
        }

        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let config = YospaceSourceConfiguration(yospaceAssetType: .linear)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
    }

    private func loadLiveTBSE() {
        guard let streamUrl = URL(string: "https://live-manifests-aka-qa.warnermediacdn.com/csmp/cmaf/live/2011915/tbseast-cbcs-stage/master_fp.m3u8?yo.pdt=true&_fw_ae=53da17a30bd0d3c946a41c86cb5873f1&_fw_ar=1&afid=180483280&conf_csid=tbs.com_desktop_live_east&nw=42448&prof=48804:tbs_ios_live&yo.vp=false&yo.ad=true&yo.dr=true&yo.av=2&yo.pdt=true") else {
            return
        }

        let sourceConfiguration = SourceConfiguration()
        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        let drmConfiguration = FairplayConfiguration(license: URL(string: "https://fairplay-stage.license.istreamplanet.com/api/license/de4c1d30-ac22-4669-8824-19ba9a1dc128"), certificateURL: URL(string: "https://fairplay-stage.license.istreamplanet.com/api/AppCert/de4c1d30-ac22-4669-8824-19ba9a1dc128")!)
        drmConfiguration.prepare()
        sourceItem.add(drmConfiguration: drmConfiguration)
        sourceConfiguration.addSourceItem(item: sourceItem)
        let yospaceConfiguration: YospaceSourceConfiguration? = YospaceSourceConfiguration(yospaceAssetType: .linear, retryExcludingYospace: true)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfiguration, yospaceSourceConfiguration: yospaceConfiguration)
    }

    private func loadVod() {
        guard let streamUrl = URL(string: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_videopage&context=182883174&nw=42448&prof=48804%3Atbs_web_vod&vdur=1800&yo.vp=false") else {
            return
        }

        let sourceConfiguration = SourceConfiguration()
        sourceConfiguration.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let yospaceConfiguration: YospaceSourceConfiguration? = YospaceSourceConfiguration(yospaceAssetType: .vod, retryExcludingYospace: true)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfiguration, yospaceSourceConfiguration: yospaceConfiguration)
    }

    private func loadTruex() {
        guard let streamUrl = URL(string: "https://vod-manifests-aka-qa.warnermediacdn.com/csm/tcm/clear/3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c/master_cl.m3u8?afid=222591187&caid=2100555&conf_csid=tbs.com_mobile_iphone&context=182883174&nw=42448&prof=48804%3Amp4_plus_vast_truex&vdur=1800&yo.vp=true&yo.ad=true") else {
            return
        }

        let sourceConfiguration = SourceConfiguration()
        sourceConfiguration.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let yospaceConfiguration: YospaceSourceConfiguration? = YospaceSourceConfiguration(yospaceAssetType: .vod, retryExcludingYospace: true)
        let truexConfiguration = TruexConfiguration(view: bitmovinPlayerView!)

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfiguration, yospaceSourceConfiguration: yospaceConfiguration, truexConfiguration: truexConfiguration)
    }

    private func loadNonYospace() {
        guard let streamUrl = URL(string: "https://hls.pro34.lv3.cdn.hbo.com/av/videos/series/watchmen/videos/trailer/trailer-47867523_PRO34/base_index.m3u8") else {
            return
        }

        let sourceConfiguration = SourceConfiguration()
        sourceConfiguration.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))

        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfiguration)
    }

    private func updateBufferUI() {
        if #available(iOS 10.0, *) {
            bufferLabel.text = String(format: "Buffer: [%.2f %.2f]", bitmovinYospacePlayer!.buffer.getLevel(BufferType.backwardDuration).level, bitmovinYospacePlayer!.buffer.getLevel(BufferType.forwardDuration).level)
        }
    }

    private func updateAdBreakCounterUI() {

        if let activeAdBreak = bitmovinYospacePlayer?.getActiveAdBreak(), let activeAd = bitmovinYospacePlayer?.getActiveAd() {

            let adCount = activeAdBreak.ads.count
            var count = 0
            var adTimeRemaining = 0
            var adBreakTimeRemaining = activeAdBreak.duration

            let yospaceAds = activeAdBreak.ads.compactMap {$0 as? YospaceAd}
            for advertisement in yospaceAds {
                count+=1
                if advertisement.identifier == activeAd.identifier {
                    adTimeRemaining = Int(activeAd.duration - (bitmovinYospacePlayer?.currentTime ?? 0))
                    adBreakTimeRemaining -= (bitmovinYospacePlayer?.currentTime ?? 0)
                    break
                } else {
                    adBreakTimeRemaining -= advertisement.duration
                }
            }

            adBreakCounterLabel.text = String(format: "AdBreak: %ds - Ad: %d of %d %ds", Int(adBreakTimeRemaining), count, adCount, adTimeRemaining)
        } else {
            adBreakCounterLabel.text = "Ad: false"
        }
    }

    private func resetUI() {
        listItems.removeAll()
        tableView.reloadData()
        adBreakStartCount = 0
        adStartCount = 0
        adFinishCount = 0
        adBreakFinishCount = 0
        loadUnloadButton.setTitle("Load", for: .normal)
    }

    private func clearList() {
        listItems.removeAll()
        tableView.reloadData()
    }

    private func showListAds() {
        if let activeAdBreak = bitmovinYospacePlayer?.getActiveAdBreak() {
            let header = ListItem(entryOne: "Seq", entryTwo: "Id", entryThree: "Duration", entryFour: "TrueX")
            listItems.append(header)
            let yospaceAds = activeAdBreak.ads.compactMap {$0 as? YospaceAd}
            for (index, advert) in yospaceAds.enumerated() {
                let item = ListItem(
                    entryOne: String(index + 1),
                    entryTwo: advert.identifier ?? "",
                    entryThree: String(format: "%.2f", advert.duration),
                    entryFour: String(advert.hasInteractiveUnit)
                )
                listItems.append(item)
            }
            tableView.reloadData()
        }
    }

    private func showListAdBreaks() {
        if let timeline = bitmovinYospacePlayer?.timeline, !timeline.adBreaks.isEmpty {
            let header = ListItem(entryOne: "Seq", entryTwo: "Start", entryThree: "Duration", entryFour: "Ads")
            listItems.append(header)

            for (index, adBreak) in timeline.adBreaks.enumerated() {
                let item = ListItem(
                    entryOne: String(index + 1),
                    entryTwo: String(format: "%.2f", adBreak.absoluteStart),
                    entryThree: String(format: "%.2f", adBreak.duration),
                    entryFour: String(adBreak.ads.count)
                )
                listItems.append(item)
            }

            tableView.reloadData()
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return streamNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return streamNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStreamIndex = row
        streamsTextField.text = streamNames[row]
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listItems[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "list_cell", for: indexPath) as? ListCell {
            cell.setItem(item: item)
            return cell
        }
        return UITableViewCell()
    }
}

extension ViewController: PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent) {
        guard let yospaceAdStartedEvent = event as? YospaceAdStartedEvent else {
            return
        }
        NSLog("[Tub] Ad Started - truex: \(yospaceAdStartedEvent.truexAd)")
        adStartCount += 1
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        NSLog("[Tub] Ad Finished")
        adFinishCount += 1
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        adBreakCounterLabel.isHidden = false
        NSLog("[Tub] Ad Break Started")
        adBreakStartCount += 1
        clearList()
        showListAds()
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        adBreakCounterLabel.isHidden = true
        NSLog("[Tub] Ad Break Finished")
        adBreakFinishCount += 1
        clearList()
        showListAdBreaks()
    }

    public func onAdClicked(_ event: AdClickedEvent) {
        NSLog("Ad Clicked")
    }

    public func onDurationChanged(_ event: DurationChangedEvent) {
        NSLog("On Duration Changed: \(event.duration)")
    }

    public func onError(_ event: ErrorEvent) {
        NSLog("On Error: \(event.code)")
        resetUI()
    }

    public func onPlaying(_ event: PlayingEvent) {
        NSLog("On Playing: \(event.debugDescription)")
    }

    public func onReady(_ event: ReadyEvent) {
        guard let timeline = bitmovinYospacePlayer?.timeline else {
            return
        }
        showListAdBreaks()
        NSLog("On Ready: \(timeline.debugDescription)")
    }

    public func onCueEnter(_ event: CueEnterEvent) {
        NSLog("Cue Enter: \(event.startTime) - \(event.endTime)")
    }

    public func onCueExit(_ event: CueExitEvent) {
        NSLog("Cue Exit: \(event.startTime) - \(event.endTime)")
    }

    func onSourceLoaded(_ event: SourceLoadedEvent) {
        loadUnloadButton.setTitle("Unload", for: .normal)
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        loadUnloadButton.setTitle("Load", for: .normal)
    }

    public func onStallStarted(_ event: StallStartedEvent) {
        NSLog("On Stall Started")
    }

    public func onStallEnded(_ event: StallEndedEvent) {
        NSLog("On Stall Ended")
    }

    public func onTimeChanged(_ event: TimeChangedEvent) {
        updateBufferUI()
        updateAdBreakCounterUI()
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
        NSLog("[VIewController] Timeline Changed: \(event.timeline.debugDescription)")
    }

    public func onTrueXAdFree() {
        NSLog("[ViewController] On TrueXAdFree")
    }
}
