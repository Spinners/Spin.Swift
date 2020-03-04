//
//  AnyPublisher+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine
import Spin_Swift

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnyPublisher: ReactiveStream where Failure == Never {
    public typealias Value = Output
    public typealias LifeCycle = AnyCancellable

    public func spin() -> LifeCycle {
        return self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

    public func spin<PublisherType: Publisher>(after trigger: PublisherType) -> LifeCycle where PublisherType.Failure == Never {
        return trigger.flatMap { _ -> AnyPublisher<Value, Never> in
            return self
        }
        .eraseToAnyPublisher()
        .spin()
    }

    public static func emptyStream() -> Self {
        return Empty().eraseToAnyPublisher()
    }
}
