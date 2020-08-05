//
//  AnyPublisher+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import SpinCommon
import Dispatch

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension AnyPublisher where Failure == Never {
    static func stream<Event, Executer>(from spin: ScheduledSpin<Value, Event, Executer>) -> AnyPublisher<Value, Never>
        where
        Executer: ExecuterDefinition,
        Executer.Executer: Scheduler {
            return Deferred<AnyPublisher<Value, Never>> { [weak spin] in

                guard let spin = spin else { return Empty().eraseToAnyPublisher() }

                let currentState = CurrentValueSubject<Value, Never>(spin.initialState)

                // merging all the effects into one event stream
                let stateInputStream = currentState.eraseToAnyPublisher()
                let eventStreams = spin.effects.map { $0(stateInputStream) }
                let eventStream = Publishers.MergeMany(eventStreams).eraseToAnyPublisher()

                return eventStream
                    .subscribe(on: spin.executer)
                    .receive(on: spin.executer)
                    .scan(spin.initialState, spin.reducer)
                    .handleEvents(receiveOutput: currentState.send)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    static func start<Event, Executer>(spin: ScheduledSpin<Value, Event, Executer>) -> AnyCancellable
        where Executer: ExecuterDefinition, Executer.Executer: Scheduler {
        AnyPublisher.stream(from: spin).consume()
    }
}
