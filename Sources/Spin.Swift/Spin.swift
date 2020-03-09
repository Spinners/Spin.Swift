//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A Spin defines the reactive stream that outputs the feedback loop sequence of `States`
/// `AnySpin` is a concrete implementation based on an initial state, a collection of feedbacks and a reducer

public protocol Spin {
    associatedtype StateStream: ReactiveStream
    associatedtype EventStream: ReactiveStream

    var initialState: StateStream.Value { get }
    var effects: [(StateStream) -> EventStream] { get }
    var scheduledReducer: (EventStream) -> StateStream { get }

    func toReactiveStream() -> StateStream
    func start() -> StateStream.Subscription
}

public extension Spin {
    func start()  -> StateStream.Subscription {
        self.toReactiveStream().consume()
    }
}
