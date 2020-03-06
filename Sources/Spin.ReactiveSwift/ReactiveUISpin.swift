//
//  ReactiveUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import Spin_Swift

public final class ReactiveUISpin<State, Event>: ReactiveSpin<State, Event> {
    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private var externalRenderFunction: ((State) -> Void)?
    private let disposeBag = CompositeDisposable()

    public init(spin: ReactiveSpin<State, Event>) {
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = ReactiveFeedback<State, Event>(uiEffects: self.render, self.emit, on: UIScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
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
        self.externalRenderFunction?(state)
    }

    private func emit() -> SignalProducer<Event, Never> {
        self.eventsProducer.producer
    }

    deinit {
        self.disposeBag.dispose()
    }
}
