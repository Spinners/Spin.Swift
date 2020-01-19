//
//  CombineReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

public struct CombineReducer<State, Event, SchedulerTime, SchedulerOptions>: Reducer
    where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StateStream = AnyPublisher<State, Never>
    public typealias EventStream = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer

    public init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value, on executer: Executer) {
        self.reducer = reducer
        self.executer = executer
    }

    public func apply(on initialState: StateStream.Value,
                      after feedback: @escaping (StateStream) -> EventStream) -> StateStream {
        return Deferred<StateStream> {
            let currentState = CurrentValueSubject<StateStream.Value, Never>(initialState)

            return feedback(currentState.eraseToAnyPublisher())
                .receive(on: self.executer)
                .scan(initialState, self.reducer)
                .prepend(initialState)
                .handleEvents(receiveOutput: currentState.send)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    public func apply(on initialState: StateStream.Value,
                      after feedbacks: [(StateStream) -> EventStream]) -> StateStream {
        let feedback = { stateStream in
            return Publishers.MergeMany(feedbacks.map { $0(stateStream) }).eraseToAnyPublisher()
        }

        return self.apply(on: initialState, after: feedback)
    }
}

public typealias DispatchQueueCombineReducer<State, Event>
    = CombineReducer<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

public extension CombineReducer
    where SchedulerTime == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value) {
        self.init(reducer: reducer, on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
