//
//  CombineFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

public struct CombineFeedback<State, Event, SchedulerTime, SchedulerOptions>: Feedback
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
            case .continueOnNewEvent:
                return states.flatMap(effect).eraseToAnyPublisher()
            case .cancelOnNewEvent:
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
}

public extension CombineFeedback
    where
    SchedulerTime == DispatchQueue.SchedulerTimeType,
    SchedulerOptions == DispatchQueue.SchedulerOptions {
    init(viewContext: CombineViewContext<State, Event>) {
        self.init(uiEffects: viewContext.toStateEffect(), viewContext.toEventEffect(), on: DispatchQueue.main.eraseToAnyScheduler())
    }
}

public typealias DispatchQueueCombineFeedback<State, Event> =
    CombineFeedback<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
