//
//  Observable+streamFromSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-07.
//

import RxRelay
import RxSwift
import SpinCommon

public extension Observable {
    static func stream<Event>(from spin: Spin<Element, Event>) -> Observable<Element> {
        return Observable<Element>.deferred { [weak spin] in

            guard let spin = spin else { return .empty() }

            let currentState = BehaviorRelay<Element>(value: spin.initialState)

            // merging all the effects into one event stream
            let stateInputStream = currentState.asObservable()
            let eventStreams = spin.effects.map { $0(stateInputStream) }
            let eventStream = Observable<Event>.merge(eventStreams).catchError { _ in return .empty() }

            return eventStream
                .subscribeOn(spin.executer)
                .observeOn(spin.executer)
                .scan(spin.initialState, accumulator: spin.reducer)
                .do(onNext: { currentState.accept($0) })
        }
    }

    static func start<Event>(spin: Spin<Element, Event>) -> Disposable {
        Observable.stream(from: spin).consume()
    }
}
