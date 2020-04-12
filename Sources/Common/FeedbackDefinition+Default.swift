//
//  FeedbackDefinition+Default.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

public enum FeedbackFilterError: Error {
    case effectIsNotExecuted
}

public extension FeedbackDefinition {
    static var defaultExecutionStrategy: ExecutionStrategy {
        return .cancelOnNewState
    }

    /// Set an executer for the feedback after its initilization
    /// - Parameter executer: the executer on which the feedback (the underlying reactive streams) will be executed
    func execute(on executer: Executer) -> Self {
        let newFeedback = Self(effect: self.effect, on: executer)
        return newFeedback
    }
 
    /// Initialize the feedback with a: State -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter
    /// - Parameters:
    ///   - effect: the function transforming a `State` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`.
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init(effect: @escaping (StateStream.Value) -> EventStream,
         filteredBy filter: @escaping (StateStream.Value) -> Bool,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard filter(state) else {
                return EventStream.emptyStream()
            }

            return effect(state)
        }

        self.init(effect: effectWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: SubState -> ReactiveStream<Event> stream, dismissing the `State` values that
    /// don't match the filter.
    /// The returned Result allows to extract a SubState from the State and to pass it to the feedback function
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - filter: the filter to apply to the input `State`. It should return .success(value) in case the feedabck should be executed
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   filteredByResult filter: @escaping (StateStream.Value) -> Result<SubState, FeedbackFilterError>,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectWithFilter: (StateStream.Value) -> EventStream = { state -> EventStream in
            guard case let .success(substate) = filter(state) else {
                return EventStream.emptyStream()
            }

            return effect(substate)
        }

        self.init(effect: effectWithFilter, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: State -> Void stream
    /// - Parameters:
    ///   - effect: the function transforming a `State` to a Void output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(effect: @escaping (StateStream.Value) -> Void, on executer: Executer? = nil) {
        let effectFromStateValue: (StateStream.Value) -> EventStream = { state -> EventStream in
            effect(state)
            return EventStream.emptyStream()
        }

        self.init(effect: effectFromStateValue, on: executer, applying: Self.defaultExecutionStrategy)
    }

    /// Initialize the feedback with a: Void -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - effect: the function transforming a Void input to a ReactiveStream<Event> output
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    init(effect: @escaping () -> EventStream, on executer: Executer? = nil) {
        let effectFromEventStream: (StateStream) -> EventStream = { _ -> EventStream in
            return effect()
        }

        self.init(effect: effectFromEventStream, on: executer)
    }

    /// Initialize the feedback with 2 separate uiEffects
    /// - Parameters:
    ///   - stateEffect: the effect when receiving a new State
    ///   - eventEffect: the effect outputing new Events
    ///   - executer: the `Executer` upon which the 2 feedbacks will be executed (default is nil)
    init(uiEffects stateEffect: @escaping (StateStream.Value) -> Void,
         _ eventEffect: @escaping () -> EventStream,
         on executer: Executer? = nil) {
        let stateFeedback = Self(effect: stateEffect, on: executer)
        let eventFeedback = Self(effect: eventEffect, on: executer)

        self.init(effects: [stateFeedback.effect, eventFeedback.effect])
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - keyPath: the keyPath to obtain the `SubState` from the State type passed as an input to the feedback
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn keyPath: KeyPath<StateStream.Value, SubState>,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromKeyPath: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = state[keyPath: keyPath]
            return effect(substate)
        }

        self.init(effect: effectFromKeyPath, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type passed as an input to the feedback
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromSubState: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return effect(substate)
        }

        self.init(effect: effectFromSubState, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream, dismissing the `SubState` values
    /// that don't match the filter
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - lense: the lense to apply to a State to obtain the `SubState` type paased as an input to the feedback
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn lense: @escaping (StateStream.Value) -> SubState,
                   filteredBy filter: @escaping (SubState) -> Bool,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromSubState: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = lense(state)
            return effect(substate)
        }

        let filterState: (StateStream.Value) -> Bool = { state -> Bool in
            return filter(lense(state))
        }

        self.init(effect: effectFromSubState, filteredBy: filterState, on: executer, applying: strategy)
    }

    /// Initialize the feedback with a: `SubState` -> ReactiveStream<Event> stream, dismissing the `SubState` values
    /// that don't match the filter
    /// - Parameters:
    ///   - effect: the function transforming a `SubState` to a reactive stream of `Event`
    ///   - keyPath: the keyPath to obtain the `SubState` from the State type passed as an input to the feedback
    ///   - filter: the filter to apply to the input `State`
    ///   - executer: the `Executer` upon which the feedback will be executed (default is nil)
    ///   - strategy: the `ExecutionStrategy` to apply when a new `State` value is given as input of the feedback while
    ///   the previous execution is still in progress
    init<SubState>(effect: @escaping (SubState) -> EventStream,
                   lensingOn keyPath: KeyPath<StateStream.Value, SubState>,
                   filteredBy filter: @escaping (SubState) -> Bool,
                   on executer: Executer? = nil,
                   applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let effectFromKeyPath: (StateStream.Value) -> EventStream = { state -> EventStream in
            let substate = state[keyPath: keyPath]
            return effect(substate)
        }

        let filterState: (StateStream.Value) -> Bool = { state -> Bool in
            return filter(state[keyPath: keyPath])
        }

        self.init(effect: effectFromKeyPath, filteredBy: filterState, on: executer, applying: strategy)
    }
}
