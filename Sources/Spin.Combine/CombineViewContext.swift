//
//  CombineViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch

public class CombineViewContext<State, Mutation>: ObservableObject {

    @Published
    public var state: State

    private let mutations = PassthroughSubject<Mutation, Never>()

    public init(state: State) {
        self.state = state
    }

    public func send(mutation: Mutation) {
        self.mutations.send(mutation)
    }

    public func toFeedback() -> DispatchQueueCombineFeedback<State, Mutation> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
        }

        let mutationFeedbackFunction: () -> AnyPublisher<Mutation, Never> = { [weak self] () in
            guard let strongSelf = self else { return Empty().eraseToAnyPublisher() }
            
            return strongSelf.mutations.eraseToAnyPublisher()
        }

        return DispatchQueueCombineFeedback(uiFeedbacks: renderFeedbackFunction,
                                            mutationFeedbackFunction,
                                            on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
