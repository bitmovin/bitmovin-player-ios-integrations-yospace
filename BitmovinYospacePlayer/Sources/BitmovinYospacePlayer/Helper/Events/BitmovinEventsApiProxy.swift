import BitmovinPlayerCore
import Combine
import Foundation

class BitmovinEventsApiProxy: PlayerEventsApi {
    let eventBus: EventBus

    init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    override func on<T: PlayerEvent>(_ eventType: T.Type) -> AnyPublisher<T, Never> {
        eventBus.subscribe(eventType: eventType)
    }
}
