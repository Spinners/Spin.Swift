//
//  ReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Spin_Swift
import XCTest

fileprivate class SpyReducer: Reducer {
    let reducer: (MockState, MockEvent) -> MockState
    let executer: MockExecuter

    var reduceIsCalled = false
    var numberOfEffects = 0

    required init(reducer: @escaping (MockState, MockEvent) -> MockState, on executer: MockExecuter = MockExecuter()) {
        self.reducer = reducer
        self.executer = executer
    }

    func apply(on initialState: MockState,
               after effects: [(MockStream<MockState>) -> MockStream<MockEvent>]) -> MockStream<MockState> {
        self.reduceIsCalled = true
        self.numberOfEffects = effects.count
        effects.forEach { _ = $0(MockStream<MockState>(value: initialState)) }
        _ = self.reducer(initialState, MockEvent(value: 0))
        return MockStream<MockState>(value: MockState(subState: 1701))
    }
}

final class ReducerTests: XCTestCase {

    func test_executeOn_creates_a_reducer_with_the_expected_executer() {
        // Given: a reducer with a default `Executer`
        let reducerFunction: (MockState, MockEvent) -> MockState = { state, event in
            return state
        }

        let expectedExecuter = MockExecuter()

        // When: mutating the `Executer` after the reducers's initialization
        let reducer = SpyReducer(reducer: reducerFunction).execute(on: expectedExecuter)

        // Then: the new executer is the one that is retained
        XCTAssertEqual(reducer.executer.id, expectedExecuter.id)
    }
}
