//
//  Feedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias ScheduledCombineFeedback = SpinCombine.ScheduledFeedback

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineFeedback = SpinCombine.Feedback

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias Feedback<State, Event> =
    ScheduledFeedback<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ScheduledFeedback<State, Event, SchedulerTime, SchedulerOptions>: FeedbackDefinition
where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StateStream = AnyPublisher<State, Never>
    public typealias EventStream = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let effect: (StateStream) -> EventStream

    public init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        guard let executer = executer else {
            self.effect = effect
            return
        }

        self.effect = { stateStream in
            return effect(stateStream.receive(on: executer).eraseToAnyPublisher()).eraseToAnyPublisher()
        }
    }

    public init(effect: @escaping (StateStream.Value) -> EventStream,
                on executer: Executer? = nil,
                applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let fullEffect: (StateStream) -> EventStream = { states in
            switch strategy {
            case .continueOnNewState:
                return states.flatMap(effect).eraseToAnyPublisher()
            case .cancelOnNewState:
                return states.map(effect).switchToLatest().eraseToAnyPublisher()
            }
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect).eraseToAnyPublisher()
        }

        self.init(effect: fullEffect, on: executer)
    }

    public init(effects: [(StateStream) -> EventStream]) {
        let fullEffect: (StateStream) -> EventStream = { states in
            let eventStreams = effects.map { $0(states) }
            return Publishers.MergeMany(eventStreams).eraseToAnyPublisher()
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
                .eraseToAnyPublisher()
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
