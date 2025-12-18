import BitmovinPlayerCore
import Combine
import Foundation

class EventBus {
    private weak var yospacePlayer: BitmovinYospacePlayer?
    private weak var player: Player?
    private let eventSubjectStorage: EventSubjectStorage
    private var listeners: [PlayerListener] = []
    private var yospaceListeners: [YospaceListener] = []

    init(
        player: Player,
        eventSubjectStorage: EventSubjectStorage = EventSubjectStorage()
    ) {
        self.player = player
        self.eventSubjectStorage = eventSubjectStorage
    }

    func register(yospacePlayer: BitmovinYospacePlayer) {
        self.yospacePlayer = yospacePlayer
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

        emitOnLegacyEventBus(event: event)
    }

    func add(playerListener: PlayerListener) {
        listeners.append(playerListener)
    }

    func remove(playerListener: PlayerListener) {
        listeners = listeners.filter { $0 !== playerListener }
    }

    func add(yospaceListener: YospaceListener) {
        yospaceListeners.append(yospaceListener)
    }

    func remove(yospaceListener: YospaceListener) {
        yospaceListeners = yospaceListeners.filter { $0 !== yospaceListener }
    }

    func destroy() {
        yospaceListeners.removeAll()
        listeners.removeAll()
    }

    private func emitOnLegacyEventBus(event: Event) {
        switch event {
        case let event as BitmovinYospaceEvent:
            emit(event: event)
        default:
            emit(playerEvent: event)
        }
    }

    // This handles Player and Source Events which are emitted through the Player
    private func emit(playerEvent event: Event) {
        guard let player else {
            return
        }

        let selector = buildSelector(for: event, sender: player)
        listeners.forEach { listener in
            if listener.responds(to: selector) {
                listener.perform(selector, with: event, with: player)
            }

            listener.onEvent?(event, player: player)
        }
    }

    private func emit(event: BitmovinYospaceEvent) {
        guard let yospacePlayer else {
            return
        }

        let selector = buildSelector(for: event, sender: yospacePlayer)
        yospaceListeners.forEach { listener in
            if listener.responds(to: selector) {
                listener.perform(selector, with: event, with: yospacePlayer)
            }
        }
    }
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

private func buildSelector(for event: Event, sender: Any) -> Selector {
    let suffix: String
    switch sender {
    case is BitmovinYospacePlayer:
        suffix = "yospacePlayer:"
    case is Player:
        suffix = "player:"
    case is Source:
        suffix = "source:"
    case is PlayerView:
        suffix = "view:"
    default:
        fatalError("Unsupported sender was used: \(type(of: sender))")
    }
    var selectorString = String(describing: type(of: event))
    selectorString = selectorString.replacingOccurrences(of: "Event", with: "")
    selectorString = selectorString.replacingOccurrences(of: "_", with: "")
    selectorString = selectorString.replacingOccurrences(of: "BMP", with: "")
    selectorString = "on\(selectorString):\(suffix)"
    return Selector(selectorString)
}
