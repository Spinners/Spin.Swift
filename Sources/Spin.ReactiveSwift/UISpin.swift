//
//  UISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import Spin_Swift

public typealias ReactiveUISpin = Spin_ReactiveSwift.UISpin

public final class UISpin<State, Event>: Spin<State, Event>, StateRenderer, EventEmitter {
    private let disposeBag = CompositeDisposable()
    private let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()
    private var externalRenderFunction: ((State) -> Void)?
    public var state: State {
        didSet {
            self.externalRenderFunction?(state)
        }
    }
    
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

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
    }
    
    public func emit(_ event: Event) {
        self.eventsObserver.send(value: event)
    }

    public func start() {
        SignalProducer.start(spin: self).disposed(by: self.disposeBag)
    }
}
