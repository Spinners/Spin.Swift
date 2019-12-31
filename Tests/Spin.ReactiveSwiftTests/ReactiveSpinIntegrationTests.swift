//
//  ReactiveSpinIntegrationTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_ReactiveSwift
import Spin_Swift
import XCTest

fileprivate enum StringAction {
    case append(String)
}

fileprivate struct SutSpin: SpinDefinition {

    let feedbackAFunction: (String) -> SignalProducer<StringAction, Never>
    let feedbackBFunction: (String) -> SignalProducer<StringAction, Never>
    let feedbackCFunction: (String) -> SignalProducer<StringAction, Never>
    let reducerFunction: (String, StringAction) -> String

    var spin: ReactiveSpin<String> {
        ReactiveSpin(initialState: "initialState", reducer: ReactiveReducer(reducer: reducerFunction)) {
            ReactiveFeedback(feedback: feedbackAFunction)
            ReactiveFeedback(feedback: feedbackBFunction)
            ReactiveFeedback(feedback: feedbackCFunction)
        }
    }
}

final class ReactiveSpinIntegrationTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {
        let exp = expectation(description: "incremental states")
        var receivedStates = [String]()

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return SignalProducer<StringAction, Never>(value: .append("_a\(counter)"))
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return SignalProducer<StringAction, Never>(value: .append("_b\(counter)"))
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterC += 1
            let counter = counterC
            return SignalProducer<StringAction, Never>(value: .append("_c\(counter)"))
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        Spinner
            .from(initialState: "initialState")
            .add(feedback: ReactiveFeedback(feedback: feedbackAFunction))
            .add(feedback: ReactiveFeedback(feedback: feedbackBFunction))
            .add(feedback: ReactiveFeedback(feedback: feedbackCFunction))
            .reduce(with: ReactiveReducer(reducer: reducerFunction))
            .toReactiveStream()
            .take(first: 7)
            .collect()
            .startWithValues({ (states) in
                receivedStates = states
                exp.fulfill()
            })
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedStates, ["initialState",
                                        "initialState_a1",
                                        "initialState_a1_b1",
                                        "initialState_a1_b1_c1",
                                        "initialState_a1_b1_c1_a2",
                                        "initialState_a1_b1_c1_a2_b2",
                                        "initialState_a1_b1_c1_a2_b2_c2"])
    }

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer_using_declarative_syntax() throws {
        let exp = expectation(description: "incremental states")
        var receivedStates = [String]()

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return SignalProducer<StringAction, Never>(value: .append("_a\(counter)"))
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return SignalProducer<StringAction, Never>(value: .append("_b\(counter)"))
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> SignalProducer<StringAction, Never> in
            counterC += 1
            let counter = counterC
            return SignalProducer<StringAction, Never>(value: .append("_c\(counter)"))
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        SutSpin(feedbackAFunction: feedbackAFunction,
                feedbackBFunction: feedbackBFunction,
                feedbackCFunction: feedbackCFunction,
                reducerFunction: reducerFunction)
            .toReactiveStream()
            .take(first: 7)
            .collect()
            .startWithValues({ (states) in
                receivedStates = states
                exp.fulfill()
            })
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedStates, ["initialState",
                                        "initialState_a1",
                                        "initialState_a1_b1",
                                        "initialState_a1_b1_c1",
                                        "initialState_a1_b1_c1_a2",
                                        "initialState_a1_b1_c1_a2_b2",
                                        "initialState_a1_b1_c1_a2_b2_c2"])
    }
}
