import BitmovinPlayerCore
import Combine
import Foundation

class BitmovinEventsApiProxy: PlayerEventsApi {
    let eventBus: EventBus

    init(eventBuss: EventBus) {
        self.eventBus = eventBuss
    }

    override func on<T: PlayerEvent>(_ eventType: T.Type) -> AnyPublisher<T, Never> {
        eventBus.subscribe(eventType: eventType)
    }
}
