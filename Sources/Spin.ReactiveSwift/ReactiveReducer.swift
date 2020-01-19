//
//  ReactiveReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public struct ReactiveReducer<State, Event>: Reducer {
    public typealias StateStream = SignalProducer<State, Never>
    public typealias EventStream = SignalProducer<Event, Never>
    public typealias Executer = Scheduler

    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer

    public init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value,
                on executer: Executer = QueueScheduler.main) {
        self.reducer = reducer
        self.executer = executer
    }

    public func apply(on initialState: StateStream.Value,
                      after feedback: @escaping (StateStream) -> EventStream) -> StateStream {
        return SignalProducer.deferred {
            let currentState = MutableProperty<State>(initialState)

            return feedback(currentState.producer)
                .observe(on: self.executer)
                .scan(initialState, self.reducer)
                .prefix(value: initialState)
                .on(value: { currentState.swap($0) })
        }
    }

    public func apply(on initialState: StateStream.Value,
                      after feedbacks: [(StateStream) -> EventStream]) -> StateStream {
        let feedback = { stateStream in
            return SignalProducer.merge(feedbacks.map { $0(stateStream) })
        }

        return self.apply(on: initialState, after: feedback)
    }
}
