//
//  RxReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxRelay
import RxSwift
import Spin_Swift

public struct RxReducer<State, Event>: Reducer {
    public typealias StateStream = Observable<State>
    public typealias EventStream = Observable<Event>
    public typealias Executer = ImmediateSchedulerType

    public let reducerOnExecuter: (StateStream.Value, EventStream) -> StateStream
    
    public init(reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value,
                on executer: Executer = CurrentThreadScheduler.instance) {
        self.reducerOnExecuter = { initialState, events in
            events
                .observeOn(executer)
                .scan(initialState, accumulator: reducer)
        }
    }
}
