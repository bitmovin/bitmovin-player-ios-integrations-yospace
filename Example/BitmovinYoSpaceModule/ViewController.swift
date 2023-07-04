import BitmovinPlayer
import BitmovinYospaceModule
import UIKit

struct Stream {
    var title: String
    var contentUrl: String
    var fairplayLicenseUrl: String?
    var fairplayCertUrl: String?
    var drmHeader: String?
    var yospaceSourceConfig: YospaceSourceConfig?
}

class ViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var loadUnloadButton: UIButton!
    @IBOutlet var streamsTextField: UITextField!

    lazy var player: BitmovinYospacePlayer = {
        let playConfig = PlayerConfig()
        playConfig.playbackConfig.isAutoplayEnabled = true
        playConfig.tweaksConfig.isNativeHlsParsingEnabled = true
        playConfig.tweaksConfig.isNativeHlsParsingEnabled = true

        let integrationConfig = IntegrationConfig(enablePlayheadNormalization: true)

        let player = BitmovinYospacePlayer(
            playerConfig: playConfig,
            yospaceConfig: YospaceConfig(isDebugEnabled: true),
            integrationConfig: integrationConfig
        )
        player.add(listener: self)
        player.add(integrationListener: self)

        return player
    }()

    lazy var playerView: PlayerView = {
        let playerView = PlayerView(player: player, frame: .zero)
        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = containerView.bounds
        return playerView
    }()

    lazy var streams = [
        Stream(
            title: "Yospace Sample Stream #3",
            contentUrl: "https://csm-e-sdk-validation.bln1.yospace.com/csm/access/207411697/c2FtcGxlL21hc3Rlci5tM3U4?yo.av=3",
            yospaceSourceConfig: .init(yospaceAssetType: .vod)
        ),
        Stream(
            title: "Yospace Sampel Stream #4",
            contentUrl: "https://csm-e-sdk-validation.bln1.yospace.com/csm/access/156611618/c2FtcGxlL21hc3Rlci5tM3U4?yo.av=4",
            yospaceSourceConfig: .init(yospaceAssetType: .vod)
        )
    ]

//    lazy var playheadNormalizer = PlayheadNormalizer(player: player)

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
            action: #selector(closePicker)
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

    @IBAction func loadUnloadPressed(_: UIButton) {
        if player.isPlaying {
            player.unload()
        } else {
            loadStream(stream: streams[selectedStreamIndex])
        }
    }

    func loadStream(stream: Stream) {
        guard let streamUrl = URL(string: stream.contentUrl) else { return }
        print("Loading \(streamUrl)")

        let sourceConfig = SourceConfig(url: streamUrl, type: .hls)

        if let fairplayLicense = stream.fairplayLicenseUrl, let fairplayCert = stream.fairplayCertUrl {
            let drmConfig = FairplayConfig(license: URL(string: fairplayLicense), certificateURL: URL(string: fairplayCert)!)

            if let drmHeader = stream.drmHeader {
                print("Setting DRM header")
                drmConfig.licenseRequestHeaders = ["x-isp-token": drmHeader]
            }
            prepareDRM(config: drmConfig)
            // This needs to be commented out when running simulation
            // As simulator does not support fairplay
            sourceConfig.drmConfig = drmConfig
        }

        player.load(
            sourceConfig: sourceConfig,
            yospaceSourceConfig: stream.yospaceSourceConfig
        )
    }

    func prepareDRM(config: FairplayConfig) {
        config.prepareCertificate = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                  let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: ""))
            else {
                return data
            }
            return certResult
        }
        config.prepareContentId = { (contentId: String) -> String in
            let prepared = contentId.replacingOccurrences(of: "skd://", with: "")
            let components: [String] = prepared.components(separatedBy: "/")
            return components[2]
        }
        config.prepareMessage = { (spcData: Data, _: String) -> Data in
            spcData
        }
        config.prepareLicense = { (ckcData: Data) -> Data in
            guard let ckcString = String(data: ckcData, encoding: .utf8),
                  let ckcResult = Data(base64Encoded: ckcString.replacingOccurrences(of: "\"", with: ""))
            else {
                return ckcData
            }
            return ckcResult
        }
    }

    var timeChangedFired = false
    var prevTimeChanged = 0.0
    func detectTimeJump(time: Double) {
        if !timeChangedFired {
            prevTimeChanged = time
            timeChangedFired = true
            return
        }

        let delta = time - prevTimeChanged
        if delta > 2.0 || delta < -0.5 {
            print("[raw] Time jump detected: \(delta) [\(time), \(prevTimeChanged)] ❌")
        } else {
//            print("[raw] Time update: \(time) | \(delta)")
        }
        prevTimeChanged = time
    }

//    let playheadNormalizer: PlayheadNormalizer = PlayheadNormalizer()
    func testNormalizeTime(time _: Double) {
//        let newTime = playheadNormalizer.normalize(time: time)
//        print("[normalized] Time update: \(time) | \(newTime)")
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return streams.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return streams[row].title
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
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
    func onSourceLoaded(_: SourceLoadedEvent, player _: Player) {
        loadUnloadButton.setTitle("Unload", for: .normal)
    }

    func onTimeChanged(_ event: TimeChangedEvent, player _: Player) {
        // If it's not a yospace stream, use the external normalizer
        if streams[selectedStreamIndex].yospaceSourceConfig == nil {
            detectTimeJump(time: event.currentTime)
            testNormalizeTime(time: event.currentTime)
        } else {
            detectTimeJump(time: player.currentTimeWithAds())
        }
    }

    func onMetadataParsed(_ event: MetadataParsedEvent, player _: Player) {
        print("c.extra - metadataParsed - \(event.metadataType), \(event.metadata.entries)")
    }

    func onSourceUnloaded(_: SourceUnloadedEvent, player _: Player) {
        loadUnloadButton.setTitle("Load", for: .normal)
    }

    func onError(_ event: Event, player _: Player) {
        print("[onError] \(event.description)")
    }
}
