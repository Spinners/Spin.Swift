////
////  SpinIntegrationTests.swift
////  
////
////  Created by Thibault Wittemberg on 2019-12-31.
////

import RxSwift
import SpinRxSwift
import SpinCommon
import XCTest

fileprivate enum StringAction {
    case append(String)
}

final class SpinIntegrationTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {
        // Given: an initial state, feedbacks and a reducer
        var counterA = 0
        let effectA = { (state: String) -> Observable<StringAction> in
            counterA += 1
            let counter = counterA
            return .just(.append("_a\(counter)"))
        }

        var counterB = 0
        let effectB = { (state: String) -> Observable<StringAction> in
            counterB += 1
            let counter = counterB
            return .just(.append("_b\(counter)"))
        }

        var counterC = 0
        let effectC = { (state: String) -> Observable<StringAction> in
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
        let spin = Spinner
            .initialState("initialState")
            .feedback(Feedback(effect: effectA))
            .feedback(Feedback(effect: effectB))
            .feedback(Feedback(effect: effectC))
            .reducer(Reducer(reducerFunction))

        let receivedStates = try Observable<String>.stream(from: spin)
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
        let effectA = { (state: String) -> Observable<StringAction> in
            counterA += 1
            let counter = counterA
            return .just(.append("_a\(counter)"))
        }

        var counterB = 0
        let effectB = { (state: String) -> Observable<StringAction> in
            counterB += 1
            let counter = counterB
            return .just(.append("_b\(counter)"))
        }

        var counterC = 0
        let effectC = { (state: String) -> Observable<StringAction> in
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

        let spin = Spin<String, StringAction>(initialState: "initialState") {
            Feedback(effect: effectA).execute(on: MainScheduler.instance)
            Feedback(effect: effectB).execute(on: MainScheduler.instance)
            Feedback(effect: effectC).execute(on: MainScheduler.instance)
            Reducer(reducerFunction)
        }

        // When: spinning the feedbacks and the reducer on the default executer
        let receivedStates = try Observable<String>.stream(from: spin)
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
