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

    public let reducerOnExecuter: (StateStream.Value, EventStream) -> StateStream

    public init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value,
                on executer: Executer = QueueScheduler.main) {
        self.reducerOnExecuter = { initialState, events in
            events
                .observe(on: executer)
                .scan(initialState, reducer)
        }
    }
}
