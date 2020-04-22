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

            let currentState = MutableProperty<Value>(spin.initialState)
            
            // merging all the effects into one event stream
            let eventStreams = spin.effects.map { $0(currentState.producer) }
            let eventStream = SignalProducer<Event, Never>.merge(eventStreams)
            
            return spin
                .scheduledReducer(eventStream)
                .prefix(value: spin.initialState)
                .on(value: { currentState.swap($0) })
        }
    }
    
    static func start<Event>(spin: Spin<Value, Event>) -> Disposable {
        SignalProducer.stream(from: spin).consume()
    }
}
