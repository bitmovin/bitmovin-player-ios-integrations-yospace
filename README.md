# BitmovinYoSpaceModule

##### Platforms 
iOS 9.0+
tvOS 9.2+

## Example

The following example creates a BitmovinYospacePlayer and loads a Yospace stream 

```swift
// Optionally create a yospace configuration
let yospaceConfiguration = YospaceConfiguration(debug: false, userAgent: "Custom User Agent", timeout: 5000)

// Optionally create a PlayerConfiguration
let configuration = PlayerConfiguration()

// Create a BitmovinYospacePlayer
let bitmovinYoSpacePlayer:BitmovinYospacePlayer = BitmovinYospacePlayer(configuration: configuration, yospaceConfiguration: yospaceConfiguration)


// Add it to your player view 
let playerBoundary = BMPBitmovinPlayerView(player: bitmovinYoSpacePlayer, frame: frame)
playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
playerBoundary.frame = playerView.bounds
playerView.addSubview(playerBoundary)
playerView.bringSubviewToFront(playerBoundary)

// Create a SourceConfiguration
let sourceConfig = SourceConfiguration()
sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))

// Create a YospaceSourceConfiguration with your yospaceAssetType 
let yospaceSourceConfiguration = YospaceSourceConfiguration(yospaceAssetType: .linear)

// Load your sourceConfiguration and yospaceSourceConfiguration
bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
```

#### Player Listener
```swift
// Implement the Player Listener Protocol
extension ViewController : PlayerListener {
    public func onAdStarted(_ event: AdStartedEvent) {
        print("Ad Started")
    }

    public func onAdFinished(_ event: AdFinishedEvent) {
        print("Ad Finished")
    }

    public func onAdBreakStarted(_ event: AdBreakStartedEvent) {
        print("Ad Break Started")
    }

    public func onAdBreakFinished(_ event: AdBreakFinishedEvent) {
        print("Ad Break Finished")
    }
    
    public func onAdClicked(_ event: AdClickedEvent) {
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

## Requirements

## Installation

BitmovinYospacePlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
source 'https://github.com/bitmovin/cocoapod-specs.git'
```

```ruby
  pod 'BitmovinYospaceModule', git: 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace', tag:'1.20.0'
  pod 'BitmovinPlayer', tag: '2.41.0'

  use_frameworks!
```

Then, in your command line run

```ruby
pod install
```

## Author

Cory Zachman, cory.zachman@bitmovin.com

## License

BitmovinYoSpaceModule is available under the MIT license. See the LICENSE file for more info.
