//
//  CombineUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import Spin_Swift
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class CombineUISpin<State, Event>: CombineSpin<State, Event> {
    private let events = PassthroughSubject<Event, Never>()
    private var externalRenderFunction: ((State) -> Void)?
    private var disposeBag = [AnyCancellable]()

    public init(spin: CombineSpin<State, Event>) {
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = CombineFeedback<State, Event>(uiEffects: self.render,
                                                       self.emit,
                                                       on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
    }

    public func emit(_ event: Event) {
        self.events.send(event)
    }

    private func render(state: State) {
        self.externalRenderFunction?(state)
    }

    private func emit() -> AnyPublisher<Event, Never> {
        self.events.eraseToAnyPublisher()
    }
}
