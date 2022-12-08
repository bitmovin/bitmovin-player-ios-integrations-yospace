import UIKit
import BitmovinPlayer

public class YospaceSourceConfig {
    public private(set) var yospaceAssetType: YospaceAssetType
    public private(set) var retryExcludingYospace: Bool

    // MARK: - initializer
    /**
     Initialize a new YospaceSourceConfiguration object.
     
     - Parameters:
     - yospaceAssetType: YospaceAssetType that tells the Yospace Ad Management SDK if the source is Linear, VOD, or NonLinearStartOver
     - retryExcludingYospace: Boolean describing if the player should retry the source URL without Yospace when failures occur
     */
    public init(yospaceAssetType: YospaceAssetType, retryExcludingYospace: Bool = false ) {
        self.yospaceAssetType = yospaceAssetType
        self.retryExcludingYospace = retryExcludingYospace
    }
}
