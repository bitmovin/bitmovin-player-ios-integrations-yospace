import Combine
import Foundation

public protocol YospaceEventsApi {
    func on<T: BitmovinYospaceEvent>(_ eventType: T.Type) -> AnyPublisher<T, Never>
}
