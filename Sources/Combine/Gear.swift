//
//  Gear.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

import Combine
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineGear = SpinCombine.Gear

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
open class Gear<Event>: GearDefinition {

    var eventStream: AnyPublisher<Event, Never> {
        self.eventSubject.eraseToAnyPublisher()
    }

    let eventSubject = PassthroughSubject<Event, Never>()

    public init() {}

    open func propagate(event: Event) {
        self.eventSubject.send(event)
    }
}
