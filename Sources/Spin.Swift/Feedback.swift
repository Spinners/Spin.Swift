//
//  Feedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// The strategy to apply when a new `State` value is given as input of a feedback while the previous execution is still
/// in progress
/// - continueOnNewEvent: the previous execution will go one while the new one is running
/// - cancelOnNewEvent: the previous execution will be canceled while the new one is starting
public enum ExecutionStrategy: Equatable {
    case continueOnNewEvent
    case cancelOnNewEvent
}

/// A feedback is basically a function transforming a reactive stream of `State` to a reactive stream of `Event`
/// while eventually performing side effects. The feedback can be executed on a dedicated `Executer`. If no `Executer`
/// is provided, then the feedback will be executed on the current `Executer`
public protocol Feedback {
    associatedtype StateStream: ReactiveStream
    associatedtype EventStream: ReactiveStream
    associatedtype Executer

    var effect: (StateStream) -> EventStream { get }

    init(effect: @escaping (StateStream) -> EventStream, on executer: Executer?)
    init(effect: @escaping (StateStream.Value) -> EventStream, on executer: Executer?, applying strategy: ExecutionStrategy)
    init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer?)
    init(effects: [(StateStream) -> EventStream])
}
