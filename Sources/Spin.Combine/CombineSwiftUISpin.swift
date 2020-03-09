//
//  CombineSwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import Combine
import Spin_Swift
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class CombineSwiftUISpin<State, Event>: CombineSpin<State, Event>, StateRenderer, EventEmitter, ObservableObject {
    @Published
    public var state: State
    private let events = PassthroughSubject<Event, Never>()

    public init(spin: CombineSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = CombineFeedback<State, Event>(uiEffects: { [weak self] state in
            self?.state = state
            }, { [weak self] in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                return self.events.eraseToAnyPublisher()
            }, on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func emit(_ event: Event) {
        self.events.send(event)
    }
}
