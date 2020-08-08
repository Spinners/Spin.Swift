//
//  CombineUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import SpinCommon
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineUISpin = SpinCombine.UISpin

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias UISpin<State, Event> = SpinCombine.ScheduledUISpin<State, Event, DispatchQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias RunLoopUISpin<State, Event> = SpinCombine.ScheduledUISpin<State, Event, RunLoop>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias OperationQueueUISpin<State, Event> = SpinCombine.ScheduledUISpin<State, Event, OperationQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ScheduledUISpin<State, Event, Executer>: ScheduledSpin<State, Event, Executer>, StateRenderer, EventEmitter
where Executer: ExecuterDefinition, Executer.Executer: Scheduler {
    private var subscriptions = [AnyCancellable]()
    private let events = PassthroughSubject<Event, Never>()
    private var externalRenderFunction: ((State) -> Void)?
    public var state: State {
        didSet {
            self.externalRenderFunction?(state)
        }
    }
    
    public init(spin: ScheduledSpin<State, Event, Executer>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, reducer: spin.reducer, executer: spin.executer)
        let uiFeedback = Feedback<State, Event>(uiEffects: { [weak self] state in
            self?.state = state
            }, { [weak self] in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                return self.events.eraseToAnyPublisher()
            }, on: DispatchQueue.main.eraseToAnyScheduler())

        self.effects = [uiFeedback.effect] + spin.effects
    }
    
    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
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
