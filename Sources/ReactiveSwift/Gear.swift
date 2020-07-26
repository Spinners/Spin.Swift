//
//  Gear.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

import ReactiveSwift
import SpinCommon

public typealias ReactiveGear = SpinReactiveSwift.Gear

open class Gear<Event>: GearDefinition {

    var eventStream: SignalProducer<Event, Never> {
        self.eventsProducer.producer
    }

    let (eventsProducer, eventsObserver) = Signal<Event, Never>.pipe()

    public init() {}

    open func propagate(event: Event) {
        self.eventsObserver.send(value: event)
    }
}
