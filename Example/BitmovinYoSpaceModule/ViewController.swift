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
    @IBOutlet weak var vstLabel: UILabel!
    
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

    private var bitmovinYospacePlayer: BitmovinYospacePlayer?
    private var bitmovinPlayerView: PlayerView?
    private var listItems: [ListItem] = []
    private let streamNames: [String] = ["Live CNN", "TBSE-FP", "VOD", "TrueX", "Non-Yospace"]
    private var selectedStreamIndex = 0
    private var loadPressedTime: TimeInterval = 0
    
    override func viewDidLoad() {
        createPlayer()
        createStreamPicker()
    }

    func createPlayer() {
        let configuration = PlayerConfiguration()
        configuration.playbackConfiguration.isAutoplayEnabled = true
        configuration.playbackConfiguration.isMuted = true

        let yospaceConfiguration = YospaceConfiguration(timeout: 5000, isDebugEnabled: true)
        bitmovinYospacePlayer = BitmovinYospacePlayer(configuration: configuration, yospaceConfiguration: yospaceConfiguration)
        bitmovinYospacePlayer?.add(listener: self)

        let policy: BitmovinExamplePolicy = BitmovinExamplePolicy()
        bitmovinYospacePlayer?.playerPolicy = policy

        bitmovinPlayerView = BMPBitmovinPlayerView(player: bitmovinYospacePlayer!, frame: .zero)
        bitmovinPlayerView!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        bitmovinPlayerView!.frame = containerView.bounds
        containerView.addSubview(bitmovinPlayerView!)
        containerView.bringSubviewToFront(bitmovinPlayerView!)
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
            loadPressedTime = Date().timeIntervalSince1970
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
            resetUI()
        }
    }

    @IBAction func seekPressed(_ sender: UIButton) {
       if let seekInput: String = seekTextField.text, let seekTime = TimeInterval(seekInput) {
           bitmovinYospacePlayer?.seek(time: seekTime)
       }
    }

    private func loadLiveCNN() {
        guard let streamUrl = URL(string: cnnUrl) else { return }
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let yospaceConfig = YospaceSourceConfiguration(yospaceAssetType: .linear, retryExcludingYospace: true)
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: yospaceConfig)
    }

    private func loadLiveTBSE() {
        guard let streamUrl = URL(string: tbseUrl) else { return }
        let sourceConfig = SourceConfiguration()
        let sourceItem = SourceItem(hlsSource: HLSSource(url: streamUrl))
        let drmConfig = FairplayConfiguration(license: URL(string: fairplayLicenseUrl), certificateURL: URL(string: fairplayCertUrl)!)
        drmConfig.prepare()
        sourceItem.add(drmConfiguration: drmConfig)
        sourceConfig.addSourceItem(item: sourceItem)
        let yospaceConfig = YospaceSourceConfiguration(yospaceAssetType: .linear, retryExcludingYospace: true)
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: yospaceConfig)
    }

    private func loadVod() {
        guard let streamUrl = URL(string: bonesVodUrl) else { return }
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let yospaceConfig = YospaceSourceConfiguration(yospaceAssetType: .vod, retryExcludingYospace: true)
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: yospaceConfig)
    }

    private func loadTruex() {
         guard let streamUrl = URL(string: bonesTruexUrl) else { return }
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        let yospaceConfig: YospaceSourceConfiguration? = YospaceSourceConfiguration(yospaceAssetType: .vod, retryExcludingYospace: true)
        let truexConfig = TruexConfiguration(view: bitmovinPlayerView!)
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: yospaceConfig, truexConfiguration: truexConfig)
    }

    private func loadNonYospace() {
       guard let streamUrl = URL(string: nonYospaceUrl) else { return }
        let sourceConfig = SourceConfiguration()
        sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))
        bitmovinYospacePlayer?.load(sourceConfiguration: sourceConfig)
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
            for case let advertisement as YospaceAd in activeAdBreak.ads {
                count += 1
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
        vstLabel.text = "VST: 0:000"
    }

    private func clearList() {
        listItems.removeAll()
        tableView.reloadData()
    }

    private func showListAds() {
        if let activeAdBreak = bitmovinYospacePlayer?.getActiveAdBreak() {
            let header = ListItem(entryOne: "Seq", entryTwo: "Id", entryThree: "Duration", entryFour: "TrueX")
            listItems.append(header)
            for case let (index, advert as YospaceAd) in activeAdBreak.ads.enumerated() {
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
                    entryTwo: String(format: "%.3f", adBreak.relativeStart),
                    entryThree: String(format: "%.3f", adBreak.duration),
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
    
    func onSourceLoaded(_ event: SourceLoadedEvent) {
        loadUnloadButton.setTitle("Unload", for: .normal)
    }
    
    public func onReady(_ event: ReadyEvent) {
        guard let timeline = bitmovinYospacePlayer?.timeline else { return }
        showListAdBreaks()
        NSLog("Ad timeline: \(timeline.debugDescription)")
    }
    
    public func onPlaying(_ event: PlayingEvent) {
        if vstLabel.text == "VST: 0:000" {
            let startupTime = Date().timeIntervalSince1970 - loadPressedTime
            let seconds = Int(startupTime.truncatingRemainder(dividingBy: 60))
            let millis = Int((startupTime * 1000).truncatingRemainder(dividingBy: 1000))
            vstLabel.text = String(format: "VST: \(seconds):\(millis)")
        }
    }

    public func onTimeChanged(_ event: TimeChangedEvent) {
        updateBufferUI()
        updateAdBreakCounterUI()
    }
    
    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        adBreakCounterLabel.isHidden = false
        adBreakStartCount += 1
        clearList()
        showListAds()
    }
    
    public func onAdStarted(_ event: AdStartedEvent) {
        if let yospaceAdStartedEvent = event as? YospaceAdStartedEvent {
            NSLog("onAdStarted: truex=\(yospaceAdStartedEvent.truexAd)")
        }
        adStartCount += 1
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        adFinishCount += 1
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        adBreakCounterLabel.isHidden = true
        adBreakFinishCount += 1
        clearList()
        showListAdBreaks()
    }

    public func onError(_ event: ErrorEvent) {
        resetUI()
    }

    func onSourceUnloaded(_ event: SourceUnloadedEvent) {
        loadUnloadButton.setTitle("Load", for: .normal)
    }
}
