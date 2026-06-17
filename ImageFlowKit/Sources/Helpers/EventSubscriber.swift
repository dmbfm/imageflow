import Combine

public protocol EventSubscriber: Subscriber where Input == Event, Failure == Never {
    associatedtype Event
    func receive(event: Event)
}

public extension EventSubscriber {
    func receive(completion: Subscribers.Completion<Failure>) {}
    func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }
    func receive(_ input: Input) -> Subscribers.Demand {
        self.receive(event: input)
        return .unlimited
    }
}
