//
//  ReactiveViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import ReactiveSwift

public class ReactiveViewContext<State, Mutation>: ObservableObject {
    @Published
    public var state: State

    private let (mutationsProducer, mutationsObserver) = Signal<Mutation, Never>.pipe()

    private var externalRenderFeedbackFunction: ((State) -> Void)?

    public init(state: State) {
        self.state = state
    }

    public func perform(_ mutation: Mutation) {
        self.mutationsObserver.send(value: mutation)
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFeedbackFunction = weakify(container: container, function: function)
    }

    public func toFeedback() -> ReactiveFeedback<State, Mutation> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
            self?.externalRenderFeedbackFunction?(state)
        }

        let mutationFeedbackFunction: () -> SignalProducer<Mutation, Never> = { [weak self] () in
            guard let strongSelf = self else { return .empty }

            return strongSelf.mutationsProducer.producer
        }

        return ReactiveFeedback(uiFeedbacks: renderFeedbackFunction,
                                mutationFeedbackFunction,
                                on: UIScheduler())
    }
}
