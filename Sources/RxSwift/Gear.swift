//
//  Gear.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

import RxRelay
import RxSwift
import SpinCommon

public typealias RxGear = SpinRxSwift.Gear

open class Gear<Event>: GearDefinition {

    var eventStream: Observable<Event> {
        self.eventSubject.asObservable()
    }

    let eventSubject = PublishRelay<Event>()

    public init() {}

    open func propagate(event: Event) {
        self.eventSubject.accept(event)
    }
}
