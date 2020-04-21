//
//  SwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import ReactiveSwift
import SpinCommon
import SwiftUI

#if canImport(Combine)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias ReactiveSwiftUISpin = SpinReactiveSwift.SwiftUISpin

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class SwiftUISpin<State, Event>: Spin<State, Event>, StateRenderer, EventEmitter, ObservableObject {
    @Published
    public var state: State
    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private let disposeBag = CompositeDisposable()

    public init(spin: Spin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = Feedback<State, Event>(uiEffects: { [weak self] state in
            self?.state = state
            }, { [weak self] in
                guard let `self` = self else { return .empty }
                return self.eventsProducer.producer
            }, on: UIScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func emit(_ event: Event) {
        self.eventsObserver.send(value: event)
    }

    public func start() {
        SignalProducer.start(spin: self).disposed(by: self.disposeBag)
    }

    deinit {
        self.disposeBag.dispose()
    }
}
#endif
