//
//  ReactiveUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import Spin_Swift
import SwiftUI

public final class ReactiveUISpin<State, Event>: ReactiveSpin<State, Event>, ObservableObject {
    @Published
    public var state: State

    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private var externalRenderFunction: ((State) -> Void)?
    private let disposeBag = CompositeDisposable()

    public init(spin: ReactiveSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducerOnExecuter: spin.reducerOnExecuter)
        let uiFeedback = ReactiveFeedback<State, Event>(uiEffects: self.render, self.emit, on: UIScheduler())
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
        self.eventsObserver.send(value: event)
    }

    public func toReactiveStream() -> SignalProducer<State, Never> {
        SignalProducer<State, Never>.stream(from: self)
    }

    public func spin() {
        self.toReactiveStream().start().disposed(by: self.disposeBag)
    }

    private func render(state: State) {
        self.state = state
        self.externalRenderFunction?(state)
    }

    private func emit() -> SignalProducer<Event, Never> {
        self.eventsProducer.producer
    }

    deinit {
        self.disposeBag.dispose()
    }
}
