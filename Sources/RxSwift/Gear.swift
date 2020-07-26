//
//  Gear.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

import RxSwift
import RxRelay
import SpinCommon

public typealias CombineGear = SpinRxSwift.Gear

open class Gear<Event>: GearDefinition {

    var eventStream: Observable<Event> {
        self.eventSubject.asObservable()
    }

    let eventSubject = PublishSubject<Event>()

    public init() {}

    open func propagate(event: Event) {
        self.eventSubject.onNext(event)
    }
}
