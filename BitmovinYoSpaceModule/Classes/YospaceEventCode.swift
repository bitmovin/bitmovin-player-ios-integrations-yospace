import BitmovinPlayerCore
import Foundation

@frozen
public enum YospaceErrorCode: UInt {
    case unknownError = 1000,
         invalidSource = 1001,
         noAnalytics = 1002,
         notIntialised = 1003,
         invalidPlayer = 1004
}
