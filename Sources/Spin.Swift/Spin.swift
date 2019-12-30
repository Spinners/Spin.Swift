//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public protocol SpinDefinition {
    associatedtype SpinType: Spin

    var spin: SpinType { get }
}

public extension SpinDefinition {
    func toReactiveStream() -> SpinType.StreamState {
        self.spin.stream
    }

    func spin() -> SpinType.StreamState.LifeCycle {
        self.spin.toReactiveStream().spin()
    }
}

/// A Spin defines the reactive stream that outputs the feedback loop sequence of `States`
/// `AnySpin` is a concrete implementation based on an initial state, a collection of feedbacks and a reducer
public protocol Spin {
    associatedtype StreamState: ReactiveStream

    var stream: StreamState { get }
}

public extension Spin {
    func toReactiveStream() -> StreamState {
        self.stream
    }

    func spin() -> StreamState.LifeCycle {
        self.toReactiveStream().spin()
    }
}
