//
//  SwiftUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-03.
//

import Combine
import SpinCommon
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineSwiftUISpin = SpinCombine.SwiftUISpin

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias SwiftUISpin<State: Equatable, Event> = SpinCombine.ScheduledSwiftUISpin<State, Event, DispatchQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias RunLoopSwiftUISpin<State: Equatable, Event> = SpinCombine.ScheduledSwiftUISpin<State, Event, RunLoop>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias OperationQueueSwiftUISpin<State: Equatable, Event> = SpinCombine.ScheduledSwiftUISpin<State, Event, OperationQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ScheduledSwiftUISpin<State, Event, Executer>: ScheduledSpin<State, Event, Executer>, StateRenderer, EventEmitter, ObservableObject
where Executer: ExecuterDefinition, Executer.Executer: Scheduler, State: Equatable {
    @Published
    public var state: State
    private let events = PassthroughSubject<Event, Never>()
    private var subscriptions = [AnyCancellable]()

    public init(spin: ScheduledSpin<State, Event, Executer>, extraRenderStateFunction: @escaping () -> Void = {}) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducer: spin.reducer, executer: spin.executer)
        let uiFeedback = Feedback<State, Event>(uiEffects: { [weak self] state in
            guard state != self?.state else { return }
            self?.state = state
            extraRenderStateFunction()
            }, { [weak self] in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                return self.events.eraseToAnyPublisher()
            }, on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func emit(_ event: Event) {
        self.executer.schedule { [weak self] in
            self?.events.send(event)
        }
    }

    public func start() {
        AnyPublisher.start(spin: self).store(in: &self.subscriptions)
    }

    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }
}
