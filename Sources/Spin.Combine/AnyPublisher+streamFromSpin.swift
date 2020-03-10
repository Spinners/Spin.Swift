//
//  AnyPublisher+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import Spin_Swift

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension AnyPublisher where Failure == Never {
    static func stream<Event>(from spin: CombineSpin<Value, Event>) -> AnyPublisher<Value, Never> {
        return Deferred<AnyPublisher<Value, Never>> {
            let currentState = CurrentValueSubject<Value, Never>(spin.initialState)

            // merging all the effects into one event stream
            let eventStreams = spin.effects.map { $0(currentState.eraseToAnyPublisher()) }
            let eventStream = Publishers.MergeMany(eventStreams).eraseToAnyPublisher()

            return spin
                .scheduledReducer(eventStream)
                .prepend(spin.initialState)
                .handleEvents(receiveOutput: currentState.send)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    static func start<Event>(spin: CombineSpin<Value, Event>) -> AnyCancellable {
        AnyPublisher.stream(from: spin).consume()
    }
}
