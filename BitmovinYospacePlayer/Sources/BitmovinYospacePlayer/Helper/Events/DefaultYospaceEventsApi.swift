import Combine
import Foundation

internal class DefaultYospaceEventsApi: YospaceEventsApi {
    let eventBus: EventBus

    init(eventBus: EventBus) {
        self.eventBus = eventBus
    }

    func on<T: BitmovinYospaceEvent>(_ eventType: T.Type) -> AnyPublisher<T, Never> {
        eventBus.subscribe(eventType: eventType)
    }
}
