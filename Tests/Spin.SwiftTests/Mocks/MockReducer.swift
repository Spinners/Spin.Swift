//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-07.
//

import Spin_Swift

class MockReducer: Reducer {
    typealias StateStream = MockStream<MockState>
    typealias EventStream = MockStream<MockEvent>
    typealias Executer = MockExecuter

    var reducerOnExecuter: (MockState, MockStream<MockEvent>) -> MockStream<MockState>

    required init(_ reducer: @escaping (MockState, MockEvent) -> MockState, on executer: MockExecuter = MockExecuter()) {
        self.reducerOnExecuter = { initialState, events in
            _ = reducer(initialState, MockEvent.toEmpty)
            return MockStream<MockState>(value: .toEmpty)
        }
    }
}
