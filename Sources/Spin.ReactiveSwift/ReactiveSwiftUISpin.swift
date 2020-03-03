//
//  ReactiveSwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import ReactiveSwift
import Spin_Swift
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ReactiveSwiftUISpin<State, Event>: ReactiveSpin<State, Event>, ObservableObject {
    @Published
    public var state: State
    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private let disposeBag = CompositeDisposable()

    public init(spin: ReactiveSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducerOnExecuter: spin.reducerOnExecuter)
        let uiFeedback = ReactiveFeedback<State, Event>(uiEffects: self.render, self.emit, on: UIScheduler())
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
        self.eventsObserver.send(value: event)
    }

    public func toReactiveStream() -> SignalProducer<State, Never> {
        SignalProducer<State, Never>.stream(from: self)
    }

    public func start() {
        self.toReactiveStream().start().disposed(by: self.disposeBag)
    }

    private func render(state: State) {
        self.state = state
    }

    private func emit() -> SignalProducer<Event, Never> {
        self.eventsProducer.producer
    }

    deinit {
        self.disposeBag.dispose()
    }
}
