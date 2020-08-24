//
//  Feedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import SpinCommon

public typealias ReactiveFeedback = SpinReactiveSwift.Feedback

public struct Feedback<State, Event>: FeedbackDefinition {
    public typealias StateStream = SignalProducer<State, Never>
    public typealias EventStream = SignalProducer<Event, Never>
    public typealias Executer = Scheduler

    public let effect: (StateStream) -> EventStream

    public init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.effect = effect
            return
        }

        self.effect = { stateStream in
            return effect(stateStream.observe(on: executer))
        }
    }

    public init(effect: @escaping (StateStream.Value) -> EventStream,
                on executer: Executer? = nil,
                applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let fullEffect: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewState:
                return states.flatMap(.merge, effect)
            case .cancelOnNewState:
                return states.flatMap(.latest, effect)
            }
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect)
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(effects: [(StateStream) -> EventStream]) {
        let fullEffect: (StateStream) -> EventStream = { states in
            let eventStreams = effects.map { $0(states) }
            return SignalProducer.merge(eventStreams)
        }

        self.init(effect: fullEffect, on: nil)
    }

    public init<Event>(attachedTo gear: Gear<Event>,
                       propagating block: @escaping (Event) -> EventStream.Value?,
                       on executer: Executer? = nil) {
        let effect: (StateStream) -> EventStream = { _ in
            gear
                .eventStream
                .map { block($0) }
                .compactMap { $0 }
        }

        self.init(effect: effect, on: executer)
    }

    public init<Event>(attachedTo gear: Gear<Event>,
                       catching event: Event,
                       emitting loopEvent: EventStream.Value,
                       on executer: Executer? = nil) where Event: Equatable {
        let emitFunction: (Event) -> EventStream .Value? = { gearEvent in
            if event == gearEvent {
                return loopEvent
            }

            return nil
        }

        self.init(attachedTo: gear, propagating: emitFunction, on: executer)
    }
}
