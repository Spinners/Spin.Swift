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

extension SpinIntegrationTests {
    ////////////////////////////////////////////////////////////////
    // CHECK AUTHORIZATION SPIN
    ///////////////////////////////////////////////////////////////

    // events:    checkAuthorization                 revokeUser
    //                   ↓                               ↓
    // states:   initial -> AuthorizationShouldBeChecked -> userHasBeenRevoked

    private enum CheckAuthorizationSpinState: Equatable {
        case initial
        case authorizationShouldBeChecked
        case userHasBeenRevoked
    }

    private enum CheckAuthorizationSpinEvent {
        case checkAuthorization
        case revokeUser
    }

    ////////////////////////////////////////////////////////////////
    // FETCH FEATURE FEEDBACKLOOP
    ///////////////////////////////////////////////////////////////

    // events:   userIsNotAuthorized
    //                  ↓
    // states:  initial -> unauthorized

    private enum FetchFeatureSpinState: Equatable {
        case initial
        case unauthorized
    }

    private enum FetchFeatureSpinEvent {
        case userIsNotAuthorized
    }

    ////////////////////////////////////////////////////////////////
    // Gear
    ///////////////////////////////////////////////////////////////

    private enum GearEvent {
        case authorizedIssueDetected
    }

    func testAttach_trigger_checkAuthorizationSpin_when_fetchFeatureSpin_trigger_gear() {
        let exp = expectation(description: "Gear")

        var receivedStates = [Any]()

        // Given: 2 independents spins and a shared gear
        let gear = Gear<GearEvent>()
        let fetchFeatureSpin = self.makeFetchFeatureSpin(attachedTo: gear)
        let checkAuthorizationSpin = self.makeCheckAuthorizationSpin(attachedTo: gear)

        // When: executing the 2 spins
        Observable
            .stream(from: checkAuthorizationSpin)
            .subscribe(onNext: { state in
                receivedStates.append(state)
                if state == .userHasBeenRevoked {
                    exp.fulfill()
                }
            })
            .disposed(by: self.disposeBag)

        Observable
            .stream(from:fetchFeatureSpin)
            .subscribe(onNext: { state in
                receivedStates.append(state)
            })
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 0.5)

        // Then: the stream of states produced by the spins are the expected one thanks to the propagation of the gear
        XCTAssertEqual(receivedStates[0] as? CheckAuthorizationSpinState, CheckAuthorizationSpinState.initial)
        XCTAssertEqual(receivedStates[1] as? FetchFeatureSpinState, FetchFeatureSpinState.initial)
        XCTAssertEqual(receivedStates[2] as? FetchFeatureSpinState, FetchFeatureSpinState.unauthorized)
        XCTAssertEqual(receivedStates[3] as? CheckAuthorizationSpinState, CheckAuthorizationSpinState.authorizationShouldBeChecked)
        XCTAssertEqual(receivedStates[4] as? CheckAuthorizationSpinState, CheckAuthorizationSpinState.userHasBeenRevoked)
    }
}

private extension SpinIntegrationTests {
    private func makeCheckAuthorizationSpin(attachedTo gear: Gear<GearEvent>) -> Spin<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent> {
        let checkAuthorizationSpinReducer: (CheckAuthorizationSpinState, CheckAuthorizationSpinEvent) -> CheckAuthorizationSpinState = { state, event in
            switch (state, event) {
            case (.initial, .checkAuthorization):
                return .authorizationShouldBeChecked
            case (.authorizationShouldBeChecked, .revokeUser):
                return .userHasBeenRevoked
            default:
                return state
            }
        }

        let checkAuthorizationSideEffect: (CheckAuthorizationSpinState) -> Observable<CheckAuthorizationSpinEvent> = { state in
            guard state == .authorizationShouldBeChecked else { return .empty() }
            return Observable<CheckAuthorizationSpinEvent>.just(.revokeUser)
        }

        let attachedCheckAuthorizationFeedback = Feedback<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent>(attachTo: gear,
                                                                                                                    propagating: { (event: GearEvent) in
                                                                                                                        if event == .authorizedIssueDetected {
                                                                                                                            return CheckAuthorizationSpinEvent.checkAuthorization
                                                                                                                        }
                                                                                                                        return nil
        })

        let spin = Spin<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent>(initialState: .initial) {
            Feedback<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent>(effect: checkAuthorizationSideEffect)
            attachedCheckAuthorizationFeedback
            Reducer(checkAuthorizationSpinReducer)
        }

        return spin
    }

    private func makeFetchFeatureSpin(attachedTo gear: Gear<GearEvent>) -> Spin<FetchFeatureSpinState, FetchFeatureSpinEvent> {
        let fetchFeatureSpinReducer: (FetchFeatureSpinState, FetchFeatureSpinEvent) -> FetchFeatureSpinState = { state, event in
            switch (state, event) {
            case (.initial, .userIsNotAuthorized):
                return .unauthorized
            default:
                return state
            }
        }

        let fetchFeatureSideEffect: (FetchFeatureSpinState) -> Observable<FetchFeatureSpinEvent> = { state in
            guard state == .initial else { return .empty() }
            return Observable<FetchFeatureSpinEvent>.just(.userIsNotAuthorized)
        }

        let attachedFetchFeatureFeedback = Feedback<FetchFeatureSpinState, FetchFeatureSpinEvent>(attachTo: gear,
                                                                                                  propagating: { (state: FetchFeatureSpinState) in
                                                                                                    if state == .unauthorized {
                                                                                                        return GearEvent.authorizedIssueDetected
                                                                                                    }
                                                                                                    return nil
        })

        let spin = Spin<FetchFeatureSpinState, FetchFeatureSpinEvent>(initialState: .initial) {
            Feedback<FetchFeatureSpinState, FetchFeatureSpinEvent>(effect: fetchFeatureSideEffect)
            attachedFetchFeatureFeedback
            Reducer(fetchFeatureSpinReducer)
        }

        return spin
    }
}
