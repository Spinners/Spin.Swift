//
//  CombineReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

public struct ScheduledCombineReducer<State, Event, SchedulerTime, SchedulerOptions>: Reducer
where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StateStream = AnyPublisher<State, Never>
    public typealias EventStream = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let reducerOnExecuter: (StateStream.Value, EventStream) -> StateStream

    public init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value, on executer: Executer) {
        self.reducerOnExecuter = { initialState, events in
            events
                .receive(on: executer)
                .scan(initialState, reducer)
                .eraseToAnyPublisher()
        }
    }
}

public typealias CombineReducer<State, Event>
    = ScheduledCombineReducer<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

public extension ScheduledCombineReducer
where SchedulerTime == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value) {
        self.init(reducer: reducer, on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
