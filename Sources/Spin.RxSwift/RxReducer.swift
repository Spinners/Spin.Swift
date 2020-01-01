//
//  RxReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxRelay
import RxSwift
import Spin_Swift

public struct RxReducer<State, Mutation>: Reducer {
    public typealias StreamState = Observable<State>
    public typealias StreamMutation = Observable<Mutation>
    public typealias Executer = ImmediateSchedulerType

    public let reducer: (StreamState.Value, StreamMutation.Value) -> StreamState.Value
    public let executer: Executer

    public init(reducer: @escaping (StreamState.Value, StreamMutation.Value) -> StreamState.Value,
                on executer: Executer = CurrentThreadScheduler.instance) {
        self.reducer = reducer
        self.executer = executer
    }

    public func reduce(initialState: StreamState.Value,
                       feedback: @escaping (StreamState) -> StreamMutation) -> StreamState {
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

    public func reduce(initialState: StreamState.Value,
                       feedbacks: [(StreamState) -> StreamMutation]) -> StreamState {
        let feedback = { stateStream in
            return Observable.merge(feedbacks.map { $0(stateStream) })
        }

        return self.reduce(initialState: initialState, feedback: feedback)
    }
}
