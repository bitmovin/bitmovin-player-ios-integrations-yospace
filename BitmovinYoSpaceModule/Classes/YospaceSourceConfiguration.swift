import UIKit
import BitmovinPlayer

public class YospaceSourceConfiguration {
    let yospaceAssetType: YospaceAssetType
    let debug: Bool
    let userAgent: String?
    let timeout: TimeInterval?
    
    public convenience init(yospaceAssetType: YospaceAssetType) {
        self.init(yospaceAssetType: yospaceAssetType, userAgent:nil, timeout: nil,debug: false)
    }
    
    public convenience init(yospaceAssetType: YospaceAssetType, userAgent: String, timeout: TimeInterval?) {
        self.init(yospaceAssetType: yospaceAssetType, userAgent:userAgent, timeout: timeout, debug: false)
    }
    
    public init(yospaceAssetType: YospaceAssetType, userAgent: String?, timeout: TimeInterval?, debug: Bool) {
        self.yospaceAssetType = yospaceAssetType
        self.userAgent = userAgent
        self.debug = debug
        self.timeout = timeout
    }
}
