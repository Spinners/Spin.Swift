//
//  MockReducer.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift

class MockReducer: Reducer {
    let reducer: (MockState, MockAction) -> MockState
    let executer: MockExecuter

    var reduceIsCalled = false
    var numberOfFeedbacks = 0

    required init(reducer: @escaping (MockState, MockAction) -> MockState, on executer: MockExecuter = MockExecuter()) {
        self.reducer = reducer
        self.executer = executer
    }

    func apply(on initialState: MockState,
               after feedback: (MockStream<MockState>) -> MockStream<MockAction>) -> MockStream<MockState> {
        self.reduceIsCalled = true
        self.numberOfFeedbacks = 1
        _ = feedback(MockStream<MockState>(value: initialState))
        _ = self.reducer(initialState, MockAction(value: 0))
        return MockStream<MockState>(value: MockState(subState: 1701))
    }

    func apply(on initialState: MockState,
               after feedbacks: [(MockStream<MockState>) -> MockStream<MockAction>]) -> MockStream<MockState> {
        self.reduceIsCalled = true
        self.numberOfFeedbacks = feedbacks.count
        feedbacks.forEach { _ = $0(MockStream<MockState>(value: initialState)) }
        _ = self.reducer(initialState, MockAction(value: 0))
        return MockStream<MockState>(value: MockState(subState: 1701))
    }
}
