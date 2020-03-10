//
//  RxUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-06.
//

import RxRelay
import RxSwift
import Spin_Swift

public final class RxUISpin<State, Event>: RxSpin<State, Event>, StateRenderer, EventEmitter {
    private let disposeBag = DisposeBag()
    private let events = PublishRelay<Event>()
    private var externalRenderFunction: ((State) -> Void)?
    public var state: State {
        didSet {
            self.externalRenderFunction?(state)
        }
    }

    public init(spin: RxSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = RxFeedback<State, Event>(uiEffects: { [weak self] state in
            self?.state = state
            }, { [weak self] in
                guard let `self` = self else { return .empty() }
                return self.events.asObservable()
            }, on: MainScheduler.instance)
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
    }

    public func emit(_ event: Event) {
        self.events.accept(event)
    }

    public func start() {
        Observable.start(spin: self).disposed(by: self.disposeBag)
    }
}
