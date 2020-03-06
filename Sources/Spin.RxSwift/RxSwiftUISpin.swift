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
public final class RxSwiftUISpin<State, Event>: RxSpin<State, Event>, ObservableObject {
    @Published
    public var state: State
    private let events = PublishRelay<Event>()
    private let disposeBag = DisposeBag()

    public init(spin: RxSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = RxFeedback<State, Event>(uiEffects: self.render, self.emit, on: MainScheduler.instance)
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
        self.events.accept(event)
    }

    public func toReactiveStream() -> Observable<State> {
        Observable.stream(from: self)
    }

    public func start() {
        self.toReactiveStream().subscribe().disposed(by: self.disposeBag)
    }

    private func render(state: State) {
        self.state = state
    }

    private func emit() -> Observable<Event> {
        self.events.asObservable()
    }
}
