//
//  ReactiveViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import ReactiveSwift

public class ReactiveViewContext<State, Event>: ObservableObject {
    @Published
    public var state: State

    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()

    private var externalRenderFeedbackFunction: ((State) -> Void)?

    public init(state: State) {
        self.state = state
    }

    public func perform(_ event: Event) {
        self.eventsObserver.send(value: event)
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFeedbackFunction = weakify(container: container, function: function)
    }

    public func toFeedback() -> ReactiveFeedback<State, Event> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
            self?.externalRenderFeedbackFunction?(state)
        }

        let eventFeedbackFunction: () -> SignalProducer<Event, Never> = { [weak self] () in
            guard let strongSelf = self else { return .empty }

            return strongSelf.eventsProducer.producer
        }

        return ReactiveFeedback(uiFeedbacks: renderFeedbackFunction,
                                eventFeedbackFunction,
                                on: UIScheduler())
    }
}
