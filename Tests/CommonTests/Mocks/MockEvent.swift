//
//  MockEvent.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

struct MockEvent: CanBeEmpty, Equatable {

    let value: Int

    static var toEmpty: MockEvent {
        return MockEvent(value: 0)
    }
}
