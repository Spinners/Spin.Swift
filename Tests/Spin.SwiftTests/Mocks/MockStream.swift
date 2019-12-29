//
//  MockStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Spin_Swift

protocol CanBeEmpty {
    static var toEmpty: Self { get }
}

class MockStream<Event: CanBeEmpty> {
    var value: Event

    init(value: Event) {
        self.value = value
    }

    func flatMap<Output>(_ function: (Event) -> MockStream<Output>) -> MockStream<Output> {
        return function(self.value)
    }

    static func empty() -> MockStream<Event> {
        return MockStream<Event>(value: Event.toEmpty)
    }
}

extension MockStream: ReactiveStream {
    static func emptyStream() -> Self {
        return MockStream.empty() as! Self
    }

    typealias Value = Event
    typealias Lifecycle = MockLifecycle

    func spin() -> Lifecycle {
        return MockLifecycle()
    }
}
