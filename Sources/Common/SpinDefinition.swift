//
//  SpinDefinition.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A SpinDefinition defines the reactive stream that outputs the feedback loop sequence of `States`
/// `AnySpin` is a concrete implementation based on an initial state, a collection of feedbacks and a reducer

public protocol SpinDefinition {
    associatedtype StateStream: ReactiveStream
    associatedtype EventStream: ReactiveStream
    associatedtype Executer

    var initialState: StateStream.Value { get }
    var effects: [(StateStream) -> EventStream] { get }
    var reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value { get }
    var executer: Executer { get }
}
