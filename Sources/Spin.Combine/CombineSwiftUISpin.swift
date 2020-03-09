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
public final class CombineSwiftUISpin<State, Event>: CombineSpin<State, Event>, ObservableObject {
    @Published
    public var state: State

    private let events = PassthroughSubject<Event, Never>()
    private var disposeBag = [AnyCancellable]()

    public init(spin: CombineSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = CombineFeedback<State, Event>(uiEffects: self.render,
                                                       self.emit,
                                                       on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: @escaping (SubState) -> Event) -> Binding<SubState> {
        return Binding(get: { self.state[keyPath: keyPath] }, set: { self.emit(event($0)) })
    }

    public func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: Event) -> Binding<SubState> {
        return self.binding(for: keyPath) { _ -> Event in
            event
        }
    }

    public func emit(_ event: Event) {
        self.events.send(event)
    }

    private func render(state: State) {
        self.state = state
    }

    private func emit() -> AnyPublisher<Event, Never> {
        self.events.eraseToAnyPublisher()
    }
}
