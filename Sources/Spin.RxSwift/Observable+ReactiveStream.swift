//
//  Observable+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

extension Observable: ReactiveStream {
    public typealias Value = Element
    public typealias Executer = ImmediateSchedulerType
    public typealias LifeCycle = Disposable

    public func spin() -> LifeCycle {
        return self.subscribe()
    }

    public func spin<ObsType: ObservableType>(after trigger: ObsType) -> LifeCycle {
        return trigger.flatMap { _ in
            return self
        }.spin()
    }

    public static func emptyStream() -> Self {
        guard let emptyStream = Observable<Value>.empty() as? Self else {
            fatalError("Observable cannot be subclassed to be able to use the framework")
        }

        return emptyStream
    }
}
