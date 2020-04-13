//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-07.
//

import SpinCommon

class MockReducer: ReducerDefinition {
    typealias StateStream = MockStream<MockState>
    typealias EventStream = MockStream<MockEvent>
    typealias Executer = MockExecuter

    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer
    
    required init(_ reducer: @escaping (MockState, MockEvent) -> MockState, on executer: MockExecuter = MockExecuter()) {
        self.reducer = reducer
        self.executer = executer
    }

    public func scheduledReducer(with initialState: StateStream.Value) -> (EventStream) -> StateStream {
        return  { events in
            _ = self.reducer(initialState, MockEvent.toEmpty)
            return MockStream<MockState>(value: .toEmpty)
        }
    }
}
