//
//  Observable+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-07.
//

import RxSwift
import Spin_Swift

public extension Observable {
    static func stream<Event>(from spin: RxSpin<Element, Event>) -> Observable<Element> {
        return Observable<Element>.deferred {
            let currentState = ReplaySubject<Element>.create(bufferSize: 1)

            // merging all the effects into one event stream
            let eventStreams = spin.effects.map { $0(currentState.asObservable()) }
            let eventStream = Observable<Event>.merge(eventStreams).catchError { _ in return .empty() }

            return spin
                .reducerOnExecuter(spin.initialState, eventStream)
                .startWith(spin.initialState)
                .do(onNext: { currentState.onNext($0) })
        }
    }
}
