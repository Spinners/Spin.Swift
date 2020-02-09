//
//  AnyPublisher+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import Spin_Swift

public extension AnyPublisher where Failure == Never {
    static func stream<State, Event>(from spin: CombineSpin<State, Event>) -> AnyPublisher<State, Never> {
        return Deferred<AnyPublisher<State, Never>> {
            let currentState = CurrentValueSubject<State, Never>(spin.initialState)

            // merging all the effects into one event stream
            let eventStreams = spin.effects.map { $0(currentState.eraseToAnyPublisher()) }
            let eventStream = Publishers.MergeMany(eventStreams).eraseToAnyPublisher()

            return spin
                .reducerOnExecuter(spin.initialState, eventStream)
                .prepend(spin.initialState)
                .handleEvents(receiveOutput: currentState.send)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
