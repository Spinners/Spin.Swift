//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Spin_Combine
import Spin_Swift
import XCTest

fileprivate enum StringAction {
    case append(String)
}

fileprivate struct SutSpin: SpinDefinition {

    let feedbackAFunction: (String) -> AnyPublisher<StringAction, Never>
    let feedbackBFunction: (String) -> AnyPublisher<StringAction, Never>
    let feedbackCFunction: (String) -> AnyPublisher<StringAction, Never>
    let reducerFunction: (String, StringAction) -> String

    fileprivate var spin: CombineSpin<String> {
        CombineSpin(initialState: "initialState", reducer: DispatchQueueCombineReducer(reducer: reducerFunction)) {
            CombineFeedback(feedback: feedbackAFunction).execute(on: DispatchQueue.main.eraseToAnyScheduler())
            CombineFeedback(feedback: feedbackBFunction).execute(on: DispatchQueue.main.eraseToAnyScheduler())
            CombineFeedback(feedback: feedbackCFunction).execute(on: DispatchQueue.main.eraseToAnyScheduler())
        }
    }
}

final class CombineSpinIntegrationTests: XCTestCase {

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return Just<StringAction>(.append("_a\(counter)")).eraseToAnyPublisher()
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return Just<StringAction>(.append("_b\(counter)")).eraseToAnyPublisher()
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterC += 1
            let counter = counterC
            return Just<StringAction>(.append("_c\(counter)")).eraseToAnyPublisher()
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        let recorder = Spinner
            .from(initialState: "initialState")
            .add(feedback: DispatchQueueCombineFeedback(feedback: feedbackAFunction))
            .add(feedback: DispatchQueueCombineFeedback(feedback: feedbackBFunction))
            .add(feedback: DispatchQueueCombineFeedback(feedback: feedbackCFunction))
            .reduce(with: CombineReducer(reducer: reducerFunction))
            .toReactiveStream()
            .output(in: (0...6))
            .record()

        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedElements, ["initialState",
                                          "initialState_a1",
                                          "initialState_a1_b1",
                                          "initialState_a1_b1_c1",
                                          "initialState_a1_b1_c1_a2",
                                          "initialState_a1_b1_c1_a2_b2",
                                          "initialState_a1_b1_c1_a2_b2_c2"])
    }

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer_using_declarative_syntax() throws {

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return Just<StringAction>(.append("_a\(counter)")).eraseToAnyPublisher()
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return Just<StringAction>(.append("_b\(counter)")).eraseToAnyPublisher()
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> AnyPublisher<StringAction, Never> in
            counterC += 1
            let counter = counterC
            return Just<StringAction>(.append("_c\(counter)")).eraseToAnyPublisher()
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        let recorder = SutSpin(feedbackAFunction: feedbackAFunction,
                               feedbackBFunction: feedbackBFunction,
                               feedbackCFunction: feedbackCFunction,
            reducerFunction: reducerFunction)
            .toReactiveStream()
            .output(in: (0...6))
            .record()

        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedElements, ["initialState",
                                          "initialState_a1",
                                          "initialState_a1_b1",
                                          "initialState_a1_b1_c1",
                                          "initialState_a1_b1_c1_a2",
                                          "initialState_a1_b1_c1_a2_b2",
                                          "initialState_a1_b1_c1_a2_b2_c2"])
    }
}
