# BitmovinYoSpaceModule

##### Platforms 
iOS 14+
tvOS 14+

## Installation

BitmovinYospacePlayer is available through [CocoaPods](http://cocoapods.org).
To install the Yospace SDK please follow https://developer.yospace.com/sdk-documentation/apple/userguide/latest/en/prerequisites.html but the relevant steps are also outlined here. You will need to install the `cocoapods-art` plugin first:

```bash
gem install cocoapods-art
```

Then add the Yospace private repository:
```bash
pod repo-art add apple-sdk-release https://yospacerepo.jfrog.io/artifactory/api/pods/apple-sdk-release
```

Please make sure you have a `.netrc` file in your home directory containing your Yospace credentials!

In your `Podfile`, add the `BitmovinPlayer` repository as source:

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
```

And finally add the relevant pods:

```ruby
  pod 'BitmovinYospaceModule', git: 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace', tag:'2.0.0'
  pod 'BitmovinPlayer', tag: '3.37.0'
  pod 'YOAdManagement-Release'

  use_frameworks!
```

Then, in your command line run

```ruby
pod install
```

## Example

The following example creates a BitmovinYospacePlayer and loads a Yospace stream.

```swift
// Optionally create a yospace configuration
let yospaceConfig = YospaceConfig(debug: false, userAgent: "Custom User Agent", timeout: 5000)

// Optionally create a PlayerConfiguration
let playerConfig = PlayerConfig()

// Create a BitmovinYospacePlayer
let bitmovinYoSpacePlayer:BitmovinYospacePlayer = BitmovinYospacePlayer(playerConfig: playerConfig, yospaceConfig: yospaceConfig)


// Add it to your player view 
let playerBoundary = PlayerView(player: bitmovinYoSpacePlayer.bitmovinPlayer(), frame: frame)
playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
playerBoundary.frame = playerView.bounds
playerView.addSubview(playerBoundary)
playerView.bringSubviewToFront(playerBoundary)

// Create a SourceConfiguration
let sourceConfig = SourceConfig(url: streamUrl, type: .hls)

// Create a YospaceSourceConfiguration with your yospaceAssetType 
let yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .linear)

// Load your sourceConfig and yospaceSourceConfig
bitmovinYoSpacePlayer?.load(sourceConfig: sourceConfig, yospaceSourceConfig: yospaceSourceConfig)
```

#### Player Listener
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

#### Yospace Listener
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

##### Click Through Urls
Click through URLs will be delivered via each `AdStartedEvent`.

```swift 
bitmovinYospacePlayer?.clickThroughPressed()
```

## Author

Bitmovin, Inc.

## License

BitmovinYoSpaceModule is available under the MIT license. See the LICENSE file for more info.
