import Foundation
import UIKit

public class TruexConfiguration {
#if os(iOS)
    public private(set) var view: UIView
#else
    public private(set) var view: UIViewController
#endif
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
#if os(iOS)
    public init(view: UIView, userId: String = "", vastConfigUrl: String = "") {
        self.view = view
        self.userId = userId
        self.vastConfigUrl = vastConfigUrl
    }
#else
    public init(view: UIViewController, userId: String = "", vastConfigUrl: String = "") {
        self.view = view
        self.userId = userId
        self.vastConfigUrl = vastConfigUrl
    }
#endif
}
