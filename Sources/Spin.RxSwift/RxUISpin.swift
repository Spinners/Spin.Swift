//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-06.
//

import RxRelay
import RxSwift
import Spin_Swift
import SwiftUI

public final class RxUISpin<State, Event>: RxSpin<State, Event>, ObservableObject {
    @Published
    public var state: State

    private let events = PublishRelay<Event>()
    private var externalRenderFunction: ((State) -> Void)?
    private let disposeBag = DisposeBag()

    public init(spin: RxSpin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducerOnExecuter: spin.reducerOnExecuter)
        let uiFeedback = RxFeedback<State, Event>(uiEffects: self.render, self.emit, on: MainScheduler.instance)
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
        self.externalRenderFunction?(self.state)
    }

    public func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: @escaping (SubState) -> Event) -> Binding<SubState> {
        return Binding(get: { self.state[keyPath: keyPath] }, set: { self.emit(event($0)) })
    }

    public func emit(_ event: Event) {
        self.events.accept(event)
    }

    public func toReactiveStream() -> Observable<State> {
        Observable<State>.stream(from: self)
    }

    public func spin() {
        self.toReactiveStream().subscribe().disposed(by: self.disposeBag)
    }

    private func render(state: State) {
        self.state = state
        self.externalRenderFunction?(state)
    }

    private func emit() -> Observable<Event> {
        self.events.asObservable()
    }
}
