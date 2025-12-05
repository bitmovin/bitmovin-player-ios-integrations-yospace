import BitmovinPlayerCore
import Combine
import Foundation

internal class EventSubjectStorage {
    private let subjectFactory: () -> PassthroughSubject<Event, Never>
    private var eventSubjects: [ObjectIdentifier: PassthroughSubject<Event, Never>] = [:]

    init(subjectFactory: @escaping () -> PassthroughSubject<Event, Never> = PassthroughSubject.init) {
        self.subjectFactory = subjectFactory
    }

    func subject(eventKey: ObjectIdentifier) -> PassthroughSubject<Event, Never>? {
        eventSubjects[eventKey]
    }

    func createSubjectIfNeeded(eventKey: ObjectIdentifier) -> PassthroughSubject<Event, Never> {
        let subject: PassthroughSubject<Event, Never>
        if let existingPublisher = eventSubjects[eventKey] {
            subject = existingPublisher
        } else {
            subject = subjectFactory()
            eventSubjects[eventKey] = subject
        }
        return subject
    }
}
