//
//  MockSpinDefinition.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift

typealias MockSpin<Value: CanBeEmpty> = AnySpin<MockStream<Value>>

class MockSpinDefinition: SpinDefinition {

    var feedbackIsCalled = false
    var reducerIsCalled = false

    lazy var feedbackFunction = { (state: MockStream<MockState>) -> MockStream<MockAction> in
        self.feedbackIsCalled = true
        return .empty()
    }

    lazy var reducerFunction = { (state: MockState, action: MockAction) -> MockState in
        self.reducerIsCalled = true
        return MockState(subState: 0)
    }

    var spin: AnySpin<MockStream<MockState>> {
        MockSpin(initialState: MockState(subState: 0), reducer: MockReducer(reducer: reducerFunction)) {
            MockFeedback(feedback: feedbackFunction)
        }
    }
}
