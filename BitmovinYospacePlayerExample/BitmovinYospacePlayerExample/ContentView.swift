import BitmovinYospacePlayer
import BitmovinPlayerCore
import SwiftUI

// You can find your player license key on the player license dashboard:
// https://bitmovin.com/dashboard/player/licenses
private let playerLicenseKey = "<PLAYER_LICENSE_KEY>"

private struct Stream {
    var title: String
    var contentUrl: String
    var fairplayLicenseUrl: String?
    var fairplayCertUrl: String?
    var drmHeader: String?
    var yospaceSourceConfig: YospaceSourceConfig?
}

struct ContentView: View {
    private let player: BitmovinYospacePlayer
    private let playerViewConfig: PlayerViewConfig
    private var streams = [
        Stream(
            title: "Yospace Sample w/ pre-roll",
            contentUrl: "https://csm-e-sdk-validation.bln1.yospace.com/csm/access/156611618/c2FtcGxlL21hc3Rlci5tM3U4?yo.av=4",
            yospaceSourceConfig: .init(yospaceAssetType: .vod)
        ),
        Stream(
            title: "Yospace Sample w/o pre-roll",
            contentUrl: "https://csm-e-sdk-validation.bln1.yospace.com/csm/access/207411697/c2FtcGxlL21hc3Rlci5tM3U4?yo.av=3",
            yospaceSourceConfig: .init(yospaceAssetType: .vod)
        ),
    ]
    
    @State private var selectedStreamIndex = 0
    
    init() {
        // Create player configuration
        let playerConfig = PlayerConfig()

        // Set your player license key on the player configuration
        playerConfig.key = playerLicenseKey
        
        let playbackConfig = PlaybackConfig()
        playbackConfig.isAutoplayEnabled = true
        playerConfig.playbackConfig = playbackConfig

        // Create player instance
        player = BitmovinYospacePlayer(
            playerConfig: playerConfig,
            yospaceConfig: YospaceConfig(isDebugEnabled: true),
            integrationConfig: IntegrationConfig(enablePlayheadNormalization: true)
        )

        // Create player view configuration
        playerViewConfig = PlayerViewConfig()
    }

    var body: some View {
        VStack {
            Picker("Streams", selection: $selectedStreamIndex) {
                ForEach(streams.indices, id: \.self) {index in
                    Text(streams[index].title)
                }
            }
            VideoPlayerView(
                player: player,
                playerViewConfig: playerViewConfig
            )
            .background(Color.black)
            .cornerRadius(20)
            .padding()
        }
        .onAppear {
            loadStream(stream: streams[selectedStreamIndex])
        }
        .onChange(of: selectedStreamIndex) { streamIndex in
            print("Stream selection changed to \(streams[streamIndex].title)")
            loadStream(stream: streams[selectedStreamIndex])
        }
        .onReceive(player.events.on(PlayerEvent.self)) { (event: PlayerEvent) in
            dump(event, name: "[Player Event]", maxDepth: 2)
        }
        .onReceive(player.yospaceEvents.on(BitmovinYospaceEvent.self)) { (event: BitmovinYospaceEvent) in
            dump(event, name: "[Yospace Event]", maxDepth: 2)
        }
    }
    
    private func loadStream(stream: Stream) {
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

#Preview {
    ContentView()
}
