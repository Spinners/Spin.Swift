//
//  RxViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import RxRelay
import RxSwift

public class RxViewContext<State, Mutation>: ObservableObject {
    @Published
    public var state: State

    private let mutations = PublishRelay<Mutation>()

    private var externalRenderFeedbackFunction: ((State) -> Void)?

    public init(state: State) {
        self.state = state
    }

    public func perform(_ mutation: Mutation) {
        self.mutations.accept(mutation)
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFeedbackFunction = weakify(container: container, function: function)
    }

    public func toFeedback() -> RxFeedback<State, Mutation> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
            self?.externalRenderFeedbackFunction?(state)
        }

        let mutationFeedbackFunction: () -> Observable<Mutation> = { [weak self] () in
            guard let strongSelf = self else { return .empty() }

            return strongSelf.mutations.asObservable()
        }

        return RxFeedback(uiFeedbacks: renderFeedbackFunction,
                          mutationFeedbackFunction,
                          on: MainScheduler.instance)
    }
}
