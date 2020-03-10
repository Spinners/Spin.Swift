//
//  RxSwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import RxRelay
import RxSwift
import Spin_Swift
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class RxSwiftUISpin<State, Event>: RxSpin<State, Event>, StateRenderer, EventEmitter, ObservableObject {
    @Published
    public var state: State
    private let events = PublishRelay<Event>()
    private let disposeBag = DisposeBag()

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

    public func emit(_ event: Event) {
        self.events.accept(event)
    }

    public func start() {
        Observable.start(spin: self).disposed(by: self.disposeBag)
    }
}
