//
//  SignalProducer+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import SpinCommon

public extension SignalProducer where Error == Never {
    
    static func stream<Event>(from spin: Spin<Value, Event>) -> SignalProducer<Value, Never> {
        return SignalProducer<Value, Never>.deferred { [weak spin] in

            guard let spin = spin else { return .empty }

            let (signal, currentState) = Signal<Value, Never>.pipe()
            
            // merging all the effects into one event stream
            let stateInputStream = signal.producer
            let eventStreams = spin.effects.map { $0(stateInputStream) }
            let eventStream = SignalProducer<Event, Never>.merge(eventStreams)

            return eventStream
                .observe(on: spin.executer)
                .scan(spin.initialState, spin.reducer)
                .prefix(value: spin.initialState)
                .on(started: { currentState.send(value: spin.initialState) })
                .on(value: { currentState.send(value: $0) })
        }
    }
    
    static func start<Event>(spin: Spin<Value, Event>) -> Disposable {
        SignalProducer.stream(from: spin).consume()
    }
}
