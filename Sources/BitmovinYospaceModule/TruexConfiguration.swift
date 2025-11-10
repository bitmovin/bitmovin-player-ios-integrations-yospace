import Foundation
import UIKit

public class TruexConfiguration {
    public private(set) var view: UIView
    public private(set) var userId: String
    public private(set) var vastConfigUrl: String

    // MARK: - initializer

    /**
     Initialize a new TruexConfiguration object.

     - Parameters:
     - view:
     - userId:
     - vastConfigUrl:
     */
    public init(view: UIView, userId: String = "", vastConfigUrl: String = "") {
        self.view = view
        self.userId = userId
        self.vastConfigUrl = vastConfigUrl
    }
}
