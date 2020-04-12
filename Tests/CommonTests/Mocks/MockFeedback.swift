//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import SpinCommon

struct MockFeedback<State: CanBeEmpty, Event: CanBeEmpty>: FeedbackDefinition {
    typealias StateStream = MockStream<State>
    typealias EventStream = MockStream<Event>
    typealias Executer = MockExecuter

    var effect: (StateStream) -> EventStream
    var feedbackExecuter: Executer?

    init(effect: @escaping (StateStream) -> EventStream, on executer: Executer? = nil) {
        self.effect = effect
        self.feedbackExecuter = executer
    }

    init(effect: @escaping (StateStream.Value) -> EventStream,
         on executer: Executer? = nil,
         applying strategy: ExecutionStrategy = Self.defaultExecutionStrategy) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.flatMap(effect)
        }

        self.init(effect: fullEffect, on: executer)
    }



    init(directEffect: @escaping (StateStream.Value) -> EventStream.Value, on executer: Executer? = nil) {
        let fullEffect: (StateStream) -> EventStream = { states in
            return states.map(directEffect)
        }

        self.init(effect: fullEffect, on: executer)
    }


    init(effects: [(StateStream) -> EventStream]) {
        let effect: (StateStream) -> EventStream = { states in
            _ = effects.map { $0(states) }
            return .emptyStream()
        }

        self.init(effect: effect, on: nil)
    }
}
