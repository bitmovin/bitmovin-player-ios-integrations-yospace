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

To install the Yospace SDK please follow https://developer.yospace.com/sdk-documentation/apple/api/yosdk/latest/v3/index.html, but the relevant steps are also outlined here:

### Prerequisites

Before adding the package, you must configure the Yospace Ad Management SDK registry:

#### 1. Configure Yospace Artifactory Registry

```bash
swift package-registry set --global --scope "yospace" "https://yospacerepo.jfrog.io/artifactory/api/swift/apple-sdk-release-spm"
```

#### 2. Authenticate with Yospace Artifactory

```bash
swift package-registry login "https://yospacerepo.jfrog.io/artifactory/api/swift/apple-sdk-release-spm" --username {USER_NAME}
```

Replace `{USER_NAME}` with your Yospace username. When prompted, enter your Yospace Artifactory API key. Your credentials will be stored in the macOS keychain.

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
// Optionally create a yospace configuration
let yospaceConfig = YospaceConfig(debug: false, userAgent: "Custom User Agent", timeout: 5000)

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
let yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .linear)

// Load your sourceConfig and yospaceSourceConfig
bitmovinYospacePlayer?.load(sourceConfig: sourceConfig, yospaceSourceConfig: yospaceSourceConfig)
```

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
