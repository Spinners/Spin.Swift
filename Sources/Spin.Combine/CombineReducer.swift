//
//  CombineReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

public struct CombineReducer<State, Mutation, SchedulerTime, SchedulerOptions>: Reducer
    where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StreamState = AnyPublisher<State, Never>
    public typealias StreamMutation = AnyPublisher<Mutation, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let reducer: (StreamState.Value, StreamMutation.Value) -> StreamState.Value
    public let executer: Executer

    public init(reducer: @escaping (StreamState.Value, StreamMutation.Value) -> StreamState.Value, on executer: Executer) {
        self.reducer = reducer
        self.executer = executer
    }

    public func reduce(initialState: StreamState.Value,
                       feedback: @escaping (StreamState) -> StreamMutation) -> StreamState {
        return Deferred<StreamState> {
            let currentState = CurrentValueSubject<StreamState.Value, Never>(initialState)

            return feedback(currentState.eraseToAnyPublisher())
                .receive(on: self.executer)
                .scan(initialState, self.reducer)
                .prepend(initialState)
                .handleEvents(receiveOutput: currentState.send)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    public func reduce(initialState: StreamState.Value,
                       feedbacks: [(StreamState) -> StreamMutation]) -> StreamState {
        let feedback = { stateStream in
            return Publishers.MergeMany(feedbacks.map { $0(stateStream) }).eraseToAnyPublisher()
        }

        return self.reduce(initialState: initialState, feedback: feedback)
    }
}

public typealias DispatchQueueCombineReducer<State, Mutation>
    = CombineReducer<State, Mutation, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

public extension CombineReducer
    where SchedulerTime == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    init(reducer: @escaping (StreamState.Value, StreamMutation.Value) -> StreamState.Value) {
        self.init(reducer: reducer, on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
