//
//  ReactiveReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public struct ReactiveReducer<State, Mutation>: Reducer {
    public typealias StreamState = SignalProducer<State, Never>
    public typealias StreamMutation = SignalProducer<Mutation, Never>
    public typealias Executer = Scheduler

    public let reducer: (StreamState.Value, StreamMutation.Value) -> StreamState.Value
    public let executer: Executer

    public init(reducer: @escaping (StreamState.Value, StreamMutation.Value) -> StreamState.Value,
                on executer: Executer = QueueScheduler.main) {
        self.reducer = reducer
        self.executer = executer
    }

    public func reduce(initialState: StreamState.Value,
                       feedback: @escaping (StreamState) -> StreamMutation) -> StreamState {
        return SignalProducer.deferred {
            let currentState = MutableProperty<State>(initialState)

            return feedback(currentState.producer)
                .observe(on: self.executer)
                .scan(initialState, self.reducer)
                .prefix(value: initialState)
                .on(value: { currentState.swap($0) })
        }
    }

    public func reduce(initialState: StreamState.Value,
                       feedbacks: [(StreamState) -> StreamMutation]) -> StreamState {
        let feedback = { stateStream in
            return SignalProducer.merge(feedbacks.map { $0(stateStream) })
        }

        return self.reduce(initialState: initialState, feedback: feedback)
    }
}
