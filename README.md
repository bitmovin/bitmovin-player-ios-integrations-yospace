# Bitmovin Player Yospace Integration

This is an open-source project to enable the use of a third-party component (Yospace) with the Bitmovin Player iOS SDK.

## Maintenance and Update

This project is not part of a regular maintenance or update schedule. For any update requests, please take a look at the guidance further below.

## Contributions to this project

As an open-source project, we are pleased to accept any and all changes, updates and fixes from the community wishing to use this project. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more details on how to contribute.

## Reporting player bugs

If you come across a bug related to the player, please raise this through your support ticketing system.

## Need more help?

Should you want some help updating this project (update, modify, fix or otherwise) and can't contribute for any reason, please raise your request to your Bitmovin account team, who can discuss your request.

## Support and SLA Disclaimer

As an open-source project and not a core product offering, any request, issue or query related to this project is excluded from any SLA and Support terms that a customer might have with either Bitmovin or another third-party service provider or Company contributing to this project. Any and all updates are purely at the contributor's discretion.

Thank you for your contributions!

## Platforms 
- iOS 14+
- tvOS 14+

## Installation

BitmovinYospaceModule is available through Swift Package Manager.

To install the Yospace SDK, first obtain access and configure Swift Package Manager:

### Prerequisites

1. Log in to the [Yospace JFrog repository](https://yospacerepo.jfrog.io/ui/).
2. Open **Profile** and select **Set Me Up**.
3. Select the **Swift** package type.
4. Select the **apple-sdk-release-spm** repository.
5. Follow the generated instructions to configure and authenticate Swift Package Manager.

For further SDK details, see the [Yospace Apple SDK documentation](https://developer.yospace.com/sdk-documentation/apple/api/yosdk/latest/v3/index.html).

### Adding the Package

#### Via Xcode

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace`
3. Select the version you want to use
4. Add `BitmovinYospacePlayer` to your target

#### Via Package.swift

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace.git", from: "3.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "BitmovinYospacePlayer", package: "bitmovin-player-ios-integrations-yospace")
        ]
    )
]
```

## Example

The following example creates a BitmovinYospacePlayer and loads a Yospace stream.

```swift
// Optionally create a Yospace configuration
let yospaceConfig = YospaceConfig(
    userAgent: "Custom User Agent",
    timeout: 5000,
    yospaceDebugMode: .none
)

// Optionally create a PlayerConfiguration
let playerConfig = PlayerConfig()

// Create a BitmovinYospacePlayer
let bitmovinYospacePlayer:BitmovinYospacePlayer = BitmovinYospacePlayer(playerConfig: playerConfig, yospaceConfig: yospaceConfig)


// Add it to your player view 
let playerBoundary = PlayerView(player: bitmovinYospacePlayer.bitmovinPlayer(), frame: frame)
playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
playerBoundary.frame = playerView.bounds
playerView.addSubview(playerBoundary)
playerView.bringSubviewToFront(playerBoundary)

// Create a SourceConfiguration
let sourceConfig = SourceConfig(url: streamUrl, type: .hls)

// Create a YospaceSourceConfiguration with your yospaceAssetType 
let yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .dvrLive)

// Load your sourceConfig and yospaceSourceConfig
bitmovinYospacePlayer?.load(sourceConfig: sourceConfig, yospaceSourceConfig: yospaceSourceConfig)
```

Use `.dvrLive` for DVR Live streams. It creates a positional `YOSessionDVRLive` session and supplies playheads relative to the initial DVR window. The legacy timed-metadata `.linear` type is deprecated.

### Yospace validation logs

The example app supports an automatic validation mode that captures both log files required for a Yospace submission:

- Test 1 plays through an ad break and unloads the stream after the break finishes.
- Test 2 loads, plays, and unloads two consecutive sessions.

Capture both supported submissions on an available iPhone simulator with:

```bash
scripts/capture-yospace-validation-logs.sh --submission all
```

Use `vod` or `dvr-live-direct` instead of `all` to capture a single submission. Output and a submission manifest are written below `build/yospace-validation/`. The script builds and installs the example app by default; pass `--skip-build` to reuse the app in `build/yospace-validation-derived-data/`.

The example app uses the `BITMOVIN_PLAYER_LICENSE_KEY` environment variable when it is present, otherwise it falls back to a placeholder string. Set the environment variable or string to a valid Player license key.

To capture on a connected physical device, use its identifier from `xcrun devicectl list devices` and provide the Apple development team used to sign the app:

```bash
DEVELOPMENT_TEAM=<team-id> scripts/capture-yospace-validation-logs.sh \
  --submission all \
  --device <device-identifier>
```

The manual **Yospace Validation Logs** GitHub Actions workflow runs the same capture and uploads the logs as an artifact. It requires `YOSPACE_USER` and `YOSPACE_TOKEN` repository secrets for the Yospace Swift package registry. When the optional `BITMOVIN_PLAYER_LICENSE_KEY` repository secret is present, the workflow injects it into the example app; otherwise the app uses a placeholder.

### Player Listener
```swift
// Implement the Player Listener Protocol
extension ViewController : PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent, player: Player) {
        print("Ad Started")
    }

    public func onAdFinished(_ event: AdFinishedEvent, player: Player) {
        print("Ad Finished")
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent, player: Player) {
        print("Ad Break Started")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent, player: Player) {
        print("Ad Break Finished")
    }
    
    public func onAdClicked(_ event: AdClickedEvent, player: Player) {
        print("Ad Clicked")
    }
}

// Add your object as a listener to the BitmovinYospacePlayer
bitmovinYoSpacePlayer.add(listener: self)
```

### Yospace Listener
Errors specific to initializing a Yospace session with the Yospace Ad Management SDK will be returned though the onYospaceError event. These errors happen pre playback and result in an source never being loaded into the player. These errors will not show up in the Bitmovin Analytics. Common error scenarios include 

 - Passing a non Yospace source URL into the Yospace Player (6001)
 - No analytics returns in the Yospace URL (6002)
 - Yospace SDK unable to initialze a session (6003)
 - Invalid player passed into the Yospace SDK (6004)
 - Unknown error in the Yospace Ad Management SDK (6005)

```swift
//Implement the Player Listener Protocol

extension ViewController: YospaceListener {
    public func onYospaceError(event: ErrorEvent) {
        let message = "Error: \(event.code) -  \(event.message)"
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//Add your object as a listener to the BitmovinYospacePlayer
bitmovinYoSpacePlayer.add(yospaceListener: self)
```

#### Click Through Urls
Click through URLs will be delivered via each `AdStartedEvent`.

```swift 
bitmovinYospacePlayer?.clickThroughPressed()
```
