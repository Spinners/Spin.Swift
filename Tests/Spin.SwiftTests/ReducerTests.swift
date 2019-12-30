//
//  ReducerTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

import Spin_Swift
import XCTest

final class ReducerTests: XCTestCase {

    func test_executeOn_creates_a_reducer_with_the_expected_executer() {
        // Given: a reducer with a default `Executer`
        let reducerFunction: (MockState, MockAction) -> MockState = { state, action in
            return state
        }

        let expectedExecuter = MockExecuter()

        // When: mutating the `Executer` after the reducers's initialization
        let reducer = MockReducer(reducer: reducerFunction).execute(on: expectedExecuter)

        // Then: the new executer is the one that is retained
        XCTAssertEqual(reducer.executer.id, expectedExecuter.id)
    }
}
