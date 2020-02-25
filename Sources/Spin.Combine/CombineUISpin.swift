//
//  CombineUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import Spin_Swift
import SwiftUI

public final class CombineUISpin<State, Event>: CombineSpin<State, Event>, ObservableObject {
    @Published
    public var state: State

    private let events = PassthroughSubject<Event, Never>()
    private var externalRenderFunction: ((State) -> Void)?
    private var disposeBag = [AnyCancellable]()

    public init(spin: CombineSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducerOnExecuter: spin.reducerOnExecuter)
        let uiFeedback = CombineFeedback<State, Event>(uiEffects: self.render,
                                                                    self.emit,
                                                                    on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
        self.externalRenderFunction?(self.state)
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

    public func toReactiveStream() -> AnyPublisher<State, Never> {
        AnyPublisher<State, Never>.stream(from: self)
    }

    public func spin() {
        self.toReactiveStream().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).disposed(by: &self.disposeBag)
    }

    private func render(state: State) {
        self.state = state
        self.externalRenderFunction?(state)
    }

    private func emit() -> AnyPublisher<Event, Never> {
        self.events.eraseToAnyPublisher()
    }
}
