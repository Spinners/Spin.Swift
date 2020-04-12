//
//  SignalProducer+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import SpinCommon

extension SignalProducer: ReactiveStream where Error == Never {
    public typealias Value = Value
    public typealias Subscription = Disposable

    public static func emptyStream() -> Self {
        return .empty
    }

    public func consume() -> Subscription {
        return self.start()
    }
}
