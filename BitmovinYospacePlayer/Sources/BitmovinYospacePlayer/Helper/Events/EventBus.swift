import BitmovinPlayerCore
import Combine
import Foundation

class EventBus {
    private let eventSubjectStorage: EventSubjectStorage

    init(eventSubjectStorage: EventSubjectStorage = EventSubjectStorage()) {
        self.eventSubjectStorage = eventSubjectStorage
    }

    func subscribe<T: Event>(
        eventType: T.Type
    ) -> AnyPublisher<T, Never> {
        let eventKey = ObjectIdentifier(T.self)
        return eventSubjectStorage
            .createSubjectIfNeeded(eventKey: eventKey)
            .compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }

    func emit(
        event: Event
    ) {
        let typedEventKey = ObjectIdentifier(type(of: event))
        eventSubjectStorage.subject(eventKey: typedEventKey)?.send(event)

        guard let rootEventType = rootEventType(from: event) else { return }

        let anyEventKey = ObjectIdentifier(rootEventType)
        eventSubjectStorage.subject(eventKey: anyEventKey)?.send(event)
    }

    private func rootEventType(from event: Event) -> Event.Type? {
        switch event {
        case is PlayerEvent:
            return PlayerEvent.self
        case is SourceEvent:
            return SourceEvent.self
        case is PlayerViewEvent:
            return PlayerViewEvent.self
        case is BitmovinYospaceEvent:
            return BitmovinYospaceEvent.self
        default:
            return nil
        }
    }
}
