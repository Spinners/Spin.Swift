//
//  RxSpinIntegrationTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_RxSwift
import Spin_Swift
import XCTest

fileprivate enum StringAction {
    case append(String)
}

fileprivate struct SutSpin: SpinDefinition {

    let feedbackAFunction: (String) -> Observable<StringAction>
    let feedbackBFunction: (String) -> Observable<StringAction>
    let feedbackCFunction: (String) -> Observable<StringAction>
    let reducerFunction: (String, StringAction) -> String

    var spin: RxSpin<String> {
        RxSpin(initialState: "initialState", reducer: RxReducer(reducer: reducerFunction)) {
            RxFeedback(feedback: feedbackAFunction)
            RxFeedback(feedback: feedbackBFunction)
            RxFeedback(feedback: feedbackCFunction)
        }
    }
}

final class RxSpinIntegrationTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> Observable<StringAction> in
            counterA += 1
            let counter = counterA
            return .just(.append("_a\(counter)"))
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> Observable<StringAction> in
            counterB += 1
            let counter = counterB
            return .just(.append("_b\(counter)"))
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> Observable<StringAction> in
            counterC += 1
            let counter = counterC
            return .just(.append("_c\(counter)"))
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        let receivedStates = try Spinner
            .from(initialState: "initialState")
            .add(feedback: RxFeedback(feedback: feedbackAFunction))
            .add(feedback: RxFeedback(feedback: feedbackBFunction))
            .add(feedback: RxFeedback(feedback: feedbackCFunction))
            .reduce(with: RxReducer(reducer: reducerFunction))
            .toReactiveStream()
            .take(7)
            .toBlocking()
            .toArray()

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

        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let feedbackAFunction = { (state: String) -> Observable<StringAction> in
            counterA += 1
            let counter = counterA
            return .just(.append("_a\(counter)"))
        }

        var counterB = 0
        let feedbackBFunction = { (state: String) -> Observable<StringAction> in
            counterB += 1
            let counter = counterB
            return .just(.append("_b\(counter)"))
        }

        var counterC = 0
        let feedbackCFunction = { (state: String) -> Observable<StringAction> in
            counterC += 1
            let counter = counterC
            return .just(.append("_c\(counter)"))
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        // When: spinning the feedbacks and the reducer on the default executer
        let receivedStates = try SutSpin(feedbackAFunction: feedbackAFunction,
                                         feedbackBFunction: feedbackBFunction,
                                         feedbackCFunction: feedbackCFunction,
                                         reducerFunction: reducerFunction)
            .toReactiveStream()
            .take(7)
            .toBlocking()
            .toArray()

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
