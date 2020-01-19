//
//  RxViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import RxRelay
import RxSwift

public class RxViewContext<State, Event>: ObservableObject {
    @Published
    public var state: State

    private let events = PublishRelay<Event>()

    private var externalRenderFeedbackFunction: ((State) -> Void)?

    public init(state: State) {
        self.state = state
    }

    public func perform(_ event: Event) {
        self.events.accept(event)
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFeedbackFunction = weakify(container: container, function: function)
        self.externalRenderFeedbackFunction?(self.state)
    }

    public func toFeedback() -> RxFeedback<State, Event> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
            self?.externalRenderFeedbackFunction?(state)
        }

        let eventFeedbackFunction: () -> Observable<Event> = { [weak self] () in
            guard let strongSelf = self else { return .empty() }

            return strongSelf.events.asObservable()
        }

        return RxFeedback(uiFeedbacks: renderFeedbackFunction,
                          eventFeedbackFunction,
                          on: MainScheduler.instance)
    }
}
