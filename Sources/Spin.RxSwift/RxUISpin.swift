//
//  RxUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-06.
//

import RxRelay
import RxSwift
import Spin_Swift

public final class RxUISpin<State, Event>: RxSpin<State, Event> {
    private let events = PublishRelay<Event>()
    private var externalRenderFunction: ((State) -> Void)?
    private let disposeBag = DisposeBag()

    public init(spin: RxSpin<State, Event>) {
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = RxFeedback<State, Event>(uiEffects: self.render, self.emit, on: MainScheduler.instance)
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
    }

    public func emit(_ event: Event) {
        self.events.accept(event)
    }

    public func toReactiveStream() -> Observable<State> {
        Observable<State>.stream(from: self)
    }

    public func start() {
        self.toReactiveStream().subscribe().disposed(by: self.disposeBag)
    }

    private func render(state: State) {
        self.externalRenderFunction?(state)
    }

    private func emit() -> Observable<Event> {
        self.events.asObservable()
    }
}
