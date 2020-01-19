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
    func toReactiveStream() -> SpinType.StateStream {
        self.spin.stream
    }

    func spin() -> SpinType.StateStream.LifeCycle {
        self.spin.toReactiveStream().spin()
    }
}

/// A Spin defines the reactive stream that outputs the feedback loop sequence of `States`
/// `AnySpin` is a concrete implementation based on an initial state, a collection of feedbacks and a reducer
public protocol Spin {
    associatedtype StateStream: ReactiveStream

    var stream: StateStream { get }
}

public extension Spin {
    func toReactiveStream() -> StateStream {
        self.stream
    }

    func spin() -> StateStream.LifeCycle {
        self.toReactiveStream().spin()
    }
}
