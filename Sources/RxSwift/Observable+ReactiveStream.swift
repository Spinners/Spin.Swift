//
//  Observable+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import SpinCommon

extension Observable: ReactiveStream {
    public typealias Value = Element
    public typealias Subscription = Disposable

    public static func emptyStream() -> Self {
        guard let emptyStream = Observable<Value>.empty() as? Self else {
            fatalError("Observable cannot be subclassed to be able to get an emptyStream()")
        }

        return emptyStream
    }

    public func consume() -> Disposable {
        self.subscribe()
    }
}
