import UIKit
import BitmovinPlayer

public class YospaceSourceConfiguration {
    let yospaceAssetType: YospaceAssetType

    // MARK: - initializer
    /**
     Initialize a new YospaceSourceConfiguration object.
     
     - Parameters:
     - yospaceAssetType: YospaceAssetType that tells the Yospace Ad Management SDK if the source is Linear, VOD, or NonLinearStartOver
     */
    public init(yospaceAssetType: YospaceAssetType) {
        self .yospaceAssetType = yospaceAssetType
    }
}
