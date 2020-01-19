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
    public typealias StreamState = Observable<State>
    public typealias StreamEvent = Observable<Event>
    public typealias Executer = ImmediateSchedulerType

    public let reducer: (StreamState.Value, StreamEvent.Value) -> StreamState.Value
    public let executer: Executer

    public init(reducer: @escaping (StreamState.Value, StreamEvent.Value) -> StreamState.Value,
                on executer: Executer = CurrentThreadScheduler.instance) {
        self.reducer = reducer
        self.executer = executer
    }

    public func apply(on initialState: StreamState.Value,
                      after feedback: @escaping (StreamState) -> StreamEvent) -> StreamState {
        return Observable<StreamState.Value>.deferred {
            let currentState = ReplaySubject<State>.create(bufferSize: 1)

            return feedback(currentState.asObservable())
                .catchError { _ in return .empty() }
                .observeOn(self.executer)
                .scan(initialState, accumulator: self.reducer)
                .startWith(initialState)
                .do(onNext: { currentState.onNext($0) })
        }
    }

    public func apply(on initialState: StreamState.Value,
                      after feedbacks: [(StreamState) -> StreamEvent]) -> StreamState {
        let feedback = { stateStream in
            return Observable.merge(feedbacks.map { $0(stateStream) })
        }

        return self.apply(on: initialState, after: feedback)
    }
}
