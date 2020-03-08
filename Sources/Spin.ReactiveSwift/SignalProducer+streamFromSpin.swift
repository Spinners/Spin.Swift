//
//  SignalProducer+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import ReactiveSwift
import Spin_Swift

public extension SignalProducer where Error == Never {
    static func stream<SpinType: Spin, Event>(from spin: SpinType) -> SignalProducer<Value, Never>
        where
        SpinType.StateStream == SignalProducer<Value, Never>,
        SpinType.EventStream == SignalProducer<Event, Never> {
            return SignalProducer<Value, Never>.deferred {
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
}
