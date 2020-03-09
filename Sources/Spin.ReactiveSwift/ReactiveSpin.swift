//
//  ReactiveSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public class ReactiveSpin<State, Event>: AnySpin<SignalProducer<State, Never>, SignalProducer<Event, Never>> {
    public override func toReactiveStream() -> StateStream {
        SignalProducer<State, Never>.stream(from: self)
    }
}
