import UIKit
import BitmovinPlayer

public class YospaceSourceConfiguration {
    public let yospaceAssetType: YospaceAssetType
    public var timeout: TimeInterval = 5000
    public var debug: Bool = false
    public var userAgent: String = "BitmovinYospacePlayer"

    public init(yospaceAssetType: YospaceAssetType) {
        self.yospaceAssetType = yospaceAssetType
    }
}
