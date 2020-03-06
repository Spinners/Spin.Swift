//
//  CombineReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Spin_Swift

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ScheduledCombineReducer<State, Event, SchedulerTime, SchedulerOptions>: Reducer
where SchedulerTime: Strideable, SchedulerTime.Stride: SchedulerTimeIntervalConvertible {
    public typealias StateStream = AnyPublisher<State, Never>
    public typealias EventStream = AnyPublisher<Event, Never>
    public typealias Executer = AnyScheduler<SchedulerTime, SchedulerOptions>

    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer
    
    public init(_ reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value, on executer: Executer) {
        self.reducer = reducer
        self.executer = executer
    }

    public func scheduledReducer(with initialState: StateStream.Value) -> (EventStream) -> StateStream {
        return { events in
            events
                .receive(on: self.executer)
                .scan(initialState, self.reducer)
                .eraseToAnyPublisher()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineReducer<State, Event>
    = ScheduledCombineReducer<State, Event, DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ScheduledCombineReducer
where SchedulerTime == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    init(_ reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value) {
        self.init(reducer, on: DispatchQueue.main.eraseToAnyScheduler())
    }
}
