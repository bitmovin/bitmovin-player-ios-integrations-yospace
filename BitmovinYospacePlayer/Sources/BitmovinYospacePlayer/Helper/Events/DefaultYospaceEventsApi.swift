import Combine
import Foundation

internal class DefaultYospaceEventsApi: YospaceEventsApi {
    let eventBus: EventBus

    init(eventBuss: EventBus) {
        self.eventBus = eventBuss
    }

    func on<T: BitmovinYospaceEvent>(_ eventType: T.Type) -> AnyPublisher<T, Never> {
        eventBus.subscribe(eventType: eventType)
    }
}
