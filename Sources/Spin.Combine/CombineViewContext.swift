//
//  CombineViewContext.swift
//
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import SwiftUI

public class CombineViewContext<State, Event>: ObservableObject {

    @Published
    public var state: State

    private let events = PassthroughSubject<Event, Never>()

    private var externalRenderFeedbackFunction: ((State) -> Void)?

    public init(state: State) {
        self.state = state
    }

    public func emit(_ event: Event) {
        self.events.send(event)
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFeedbackFunction = weakify(container: container, function: function)
        self.externalRenderFeedbackFunction?(self.state)
    }


    public func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: @escaping (SubState) -> Event) -> Binding<SubState> {
        return Binding(get: { self.state[keyPath: keyPath] }, set: { self.emit(event($0)) })
    }

    public func toFeedback() -> DispatchQueueCombineFeedback<State, Event> {
        let renderFeedbackFunction: (State) -> Void = { [weak self] state in
            self?.state = state
            self?.externalRenderFeedbackFunction?(state)
        }

        let eventFeedbackFunction: () -> AnyPublisher<Event, Never> = { [weak self] () in
            guard let strongSelf = self else { return Empty().eraseToAnyPublisher() }
            
            return strongSelf.events.eraseToAnyPublisher()
        }

        return DispatchQueueCombineFeedback(uiEffects: renderFeedbackFunction,
                                            eventFeedbackFunction,
                                            on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
