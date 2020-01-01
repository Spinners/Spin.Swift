//
//  SignalProducer+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

extension SignalProducer: ReactiveStream where Error == Never {
    public typealias Value = Value
    public typealias Executer = Scheduler
    public typealias LifeCycle = Disposable

    public func spin() -> LifeCycle {
        return self.start()
    }

    public func spin<SignalProducerType>(after trigger: SignalProducerType) -> LifeCycle
        where
        SignalProducerType: SignalProducerProtocol,
        SignalProducerType.Error == Never {
            return trigger.producer.flatMap(.concat) { _ -> SignalProducer<Value, Never> in
                return self
            }.spin()
    }

    public static func emptyStream() -> Self {
        return .empty
    }
}
