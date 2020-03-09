//
//  ReactiveUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import Spin_Swift

public final class ReactiveUISpin<State, Event>: ReactiveSpin<State, Event>, StateRenderer, EventEmitter {
    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private var externalRenderFunction: ((State) -> Void)?
    public var state: State {
        didSet {
            self.externalRenderFunction?(state)
        }
    }
    
    public init(spin: ReactiveSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = ReactiveFeedback<State, Event>(uiEffects: { [weak self] state in
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
}
