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

final class ReactiveSpinIntegrationTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {
        let exp = expectation(description: "incremental states")
        var receivedStates = [String]()

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let effectA = { (state: String) -> SignalProducer<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return SignalProducer<StringAction, Never>(value: .append("_a\(counter)"))
        }

        var counterB = 0
        let effectB = { (state: String) -> SignalProducer<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return SignalProducer<StringAction, Never>(value: .append("_b\(counter)"))
        }

        var counterC = 0
        let effectC = { (state: String) -> SignalProducer<StringAction, Never> in
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
            .add(feedback: ReactiveFeedback(effect: effectA))
            .add(feedback: ReactiveFeedback(effect: effectB))
            .add(feedback: ReactiveFeedback(effect: effectC))
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
        let effectA = { (state: String) -> SignalProducer<StringAction, Never> in
            counterA += 1
            let counter = counterA
            return SignalProducer<StringAction, Never>(value: .append("_a\(counter)"))
        }

        var counterB = 0
        let effectB = { (state: String) -> SignalProducer<StringAction, Never> in
            counterB += 1
            let counter = counterB
            return SignalProducer<StringAction, Never>(value: .append("_b\(counter)"))
        }

        var counterC = 0
        let effectC = { (state: String) -> SignalProducer<StringAction, Never> in
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

        let sut = ReactiveSpin<String>(initialState: "initialState", reducer: ReactiveReducer(reducer: reducerFunction)) {
            ReactiveFeedback(effect: effectA).execute(on: UIScheduler())
            ReactiveFeedback(effect: effectB).execute(on: UIScheduler())
            ReactiveFeedback(effect: effectC).execute(on: UIScheduler())
        }

        // When: spinning the feedbacks and the reducer on the default executer
        sut
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
