# BitmovinYoSpaceModule

##### Platforms 
iOS 9.0+
tvOS 9.0+

## Example

The followin example create a BitmovinYospacePlayer and loads a Yospace stream 

```swift
//Create a BitmovinYospacePlayer
let bitmovinYoSpacePlayer:BitmovinYospacePlayer = BitmovinYospacePlayer(configuration: configuration)

//Add it to your player view 
let playerBoundary = BMPBitmovinPlayerView(player: bitmovinYoSpacePlayer, frame: frame)
playerBoundary.autoresizingMask = [.flexibleHeight, .flexibleWidth]
playerBoundary.frame = playerView.bounds
playerView.addSubview(playerBoundary)
playerView.bringSubviewToFront(playerBoundary)

//Create a SourceConfiguration
let sourceConfig = SourceConfiguration()
sourceConfig.addSourceItem(item: SourceItem(hlsSource: HLSSource(url: streamUrl)))

//Create a YospaceSourceConfiguration
let yospaceSourceConfiguration = YospaceSourceConfiguration(yoSpaceAssetType: .linear)

//Load your sourceConfiguration and yospaceSourceConfiguration
bitmovinYoSpacePlayer?.load(sourceConfiguration: sourceConfig, yospaceSourceConfiguration: config)
```

#### Player Listener
```swift
//Implement the Player Listener Protocol
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

//Add your object as a listener to the BitmovinYospacePlayer
bitmovinYoSpacePlayer.add(listener: self)
```


## Requirements

## Installation

BitmovinYospacePlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
  pod 'BitmovinYospaceModule', git: 'https://github.com/bitmovin/bitmovin-player-ios-integrations-yospace', tag:'0.1.2'
  pod 'BitmovinPlayer', git: 'https://github.com/bitmovin/bitmovin-player-ios-sdk-cocoapod.git', tag: '2.13.0'

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
