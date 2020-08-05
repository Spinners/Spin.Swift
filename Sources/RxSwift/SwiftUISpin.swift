//
//  SwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import RxRelay
import RxSwift
import SpinCommon
import SwiftUI

#if canImport(Combine)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias RxSwiftUISpin = SpinRxSwift.SwiftUISpin

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class SwiftUISpin<State, Event>: Spin<State, Event>, StateRenderer, EventEmitter, ObservableObject
where State: Equatable {
    @Published
    public var state: State
    private let events = PublishRelay<Event>()
    private let disposeBag = DisposeBag()
    
    public init(spin: Spin<State, Event>, extraRenderStateFunction: @escaping () -> Void = {}) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducer: spin.reducer, executer: spin.executer)
        let uiFeedback = Feedback<State, Event>(uiEffects: { [weak self] state in
            guard state != self?.state else { return }
            self?.state = state
            extraRenderStateFunction()
            }, { [weak self] in
                guard let `self` = self else { return .empty() }
                return self.events.asObservable()
            }, on: MainScheduler.instance)
        self.effects = [uiFeedback.effect] + spin.effects
    }
    
    public func emit(_ event: Event) {
        _ = self.executer.schedule(()) { [weak self] _ -> Disposable in
            self?.events.accept(event)
            return Disposables.create()
        }
    }
    
    public func start() {
        Observable.start(spin: self).disposed(by: self.disposeBag)
    }
}
#endif
