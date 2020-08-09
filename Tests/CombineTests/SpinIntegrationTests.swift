//
//  SpinIntegrationTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import SpinCombine
import SpinCommon
import XCTest

fileprivate enum StringAction {
    case append(String)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SpinIntegrationTests: XCTestCase {

    private var subscriptions = [AnyCancellable]()

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer() throws {
        let exp = expectation(description: "Integration")
        var receivedStatesInEffects = [String]()

        // Given: an initial state, effects and a reducer
        var counterA = 0
        let effectA = { (state: String) -> AnyPublisher<StringAction, Never> in
            guard state == "initialState" || state.dropLast().last == "c" else { return Empty().eraseToAnyPublisher() }
            counterA += 1
            let counter = counterA
            return Just<StringAction>(.append("_a\(counter)")).eraseToAnyPublisher()
        }

        var counterB = 0
        let effectB = { (state: String) -> AnyPublisher<StringAction, Never> in
            guard state.dropLast().last == "a" else { return Empty().eraseToAnyPublisher() }
            counterB += 1
            let counter = counterB
            return Just<StringAction>(.append("_b\(counter)")).eraseToAnyPublisher()
        }

        var counterC = 0
        let effectC = { (state: String) -> AnyPublisher<StringAction, Never> in
            guard state.dropLast().last == "b" else { return Empty().eraseToAnyPublisher() }
            counterC += 1
            let counter = counterC
            return Just<StringAction>(.append("_c\(counter)")).eraseToAnyPublisher()
        }

        let spyEffect = { (state: String) -> AnyPublisher<StringAction, Never> in
            receivedStatesInEffects.append(state)
            return Empty().eraseToAnyPublisher()
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
            .feedback(Feedback(effect: spyEffect))
            .reducer(Reducer(reducerFunction))

        AnyPublisher<String, Never>.stream(from: spin)
            .output(in: 0...5)
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 1)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedStatesInEffects, ["initialState",
                                                 "initialState_a1",
                                                 "initialState_a1_b1",
                                                 "initialState_a1_b1_c1",
                                                 "initialState_a1_b1_c1_a2",
                                                 "initialState_a1_b1_c1_a2_b2",
                                                 "initialState_a1_b1_c1_a2_b2_c2"])
    }

    func test_multiple_feedbacks_produces_incremental_states_while_executed_on_default_executer_using_declarative_syntax() throws {
        let exp = expectation(description: "Integration")

        var receivedStatesInEffects = [String]()

        // Given: an initial state, effect and a reducer
        var counterA = 0
        let effectA = { (state: String) -> AnyPublisher<StringAction, Never> in
            guard state == "initialState" || state.dropLast().last == "c" else { return Empty().eraseToAnyPublisher() }
            counterA += 1
            let counter = counterA
            return Just<StringAction>(.append("_a\(counter)")).eraseToAnyPublisher()
        }

        var counterB = 0
        let effectB = { (state: String) -> AnyPublisher<StringAction, Never> in
            guard state.dropLast().last == "a" else { return Empty().eraseToAnyPublisher() }
            counterB += 1
            let counter = counterB
            return Just<StringAction>(.append("_b\(counter)")).eraseToAnyPublisher()
        }

        var counterC = 0
        let effectC = { (state: String) -> AnyPublisher<StringAction, Never> in
            print("C" + state)
            guard state.dropLast().last == "b" else { return Empty().eraseToAnyPublisher() }
            counterC += 1
            let counter = counterC
            return Just<StringAction>(.append("_c\(counter)")).eraseToAnyPublisher()
        }

        let spyEffect = { (state: String) -> AnyPublisher<StringAction, Never> in
            receivedStatesInEffects.append(state)
            return Empty().eraseToAnyPublisher()
        }

        let reducerFunction = { (state: String, action: StringAction) -> String in
            switch action {
            case .append(let suffix):
                return state+suffix
            }
        }

        let spin = Spin<String, StringAction>(initialState: "initialState") {
            Feedback(effect: effectA)
            Feedback(effect: effectB)
            Feedback(effect: effectC)
            Feedback(effect: spyEffect)
            Reducer(reducerFunction)
        }

        // When: spinning the feedbacks and the reducer on the default executer
        AnyPublisher<String, Never>.stream(from: spin)
            .output(in: 0...5)
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 1)

        // Then: the states is constructed incrementally
        XCTAssertEqual(receivedStatesInEffects, ["initialState",
                                                 "initialState_a1",
                                                 "initialState_a1_b1",
                                                 "initialState_a1_b1_c1",
                                                 "initialState_a1_b1_c1_a2",
                                                 "initialState_a1_b1_c1_a2_b2",
                                                 "initialState_a1_b1_c1_a2_b2_c2"])
    }

    func test_reducer_and_feedback_are_executed_on_specified_executers() {
        let exp = expectation(description: "Scheduling")

        let expectedReducerQueueLabel = "SPIN_QUEUE_\(UUID())"
        let expectedFeedbackQueueLabel = "FEEDBACK_QUEUE_\(UUID())"

        var receivedReducerQueueLabel = ""
        var receivedFeedbackQueueLabel = ""

        let spinQueue = DispatchQueue(label: expectedReducerQueueLabel)
        let feedbackQueue = DispatchQueue(label: expectedFeedbackQueueLabel)

        let spyReducer: (String, String) -> String = { _, _ in
            receivedReducerQueueLabel = DispatchQueue.currentLabel
            return ""
        }

        let spyFeedback: (AnyPublisher<String, Never>) -> AnyPublisher<String, Never> = { states in
            states.map {
                receivedFeedbackQueueLabel = DispatchQueue.currentLabel
                return $0
            }.eraseToAnyPublisher()
        }

        let sut = Spin<String, String>(initialState: "initialState", executeOn: spinQueue) {
            Feedback<String, String>(effect: spyFeedback).execute(on: feedbackQueue.eraseToAnyScheduler())
            Reducer<String, String>(spyReducer)
        }

        AnyPublisher
            .stream(from: sut)
            .output(in: 0...0)
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { _ in })
            .store(in: &self.subscriptions)

        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(receivedFeedbackQueueLabel, expectedFeedbackQueueLabel)
        XCTAssertEqual(receivedReducerQueueLabel, expectedReducerQueueLabel)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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
        let exp1 = expectation(description: "Check Spin is initialized")
        let exp2 = expectation(description: "Gear")

        var receivedCheckAuthorization = [CheckAuthorizationSpinState]()
        var receivedFeatureStates = [FetchFeatureSpinState]()

        // Given: 2 independents spins and a shared gear
        let gear = Gear<GearEvent>()
        let fetchFeatureSpin = self.makeFetchFeatureSpin(attachedTo: gear)
        let checkAuthorizationSpin = self.makeCheckAuthorizationSpin(attachedTo: gear)

        let spyEffectFeatureSpin = { (state: FetchFeatureSpinState) -> AnyPublisher<FetchFeatureSpinEvent, Never> in
            receivedFeatureStates.append(state)
            return Empty().eraseToAnyPublisher()
        }
        fetchFeatureSpin.effects.append(Feedback<FetchFeatureSpinState, FetchFeatureSpinEvent>(effect: spyEffectFeatureSpin).effect)

        let spyEffectCheckAuthorizationSpin = { (state: CheckAuthorizationSpinState) -> AnyPublisher<CheckAuthorizationSpinEvent, Never> in
            receivedCheckAuthorization.append(state)
            if state == .initial {
                exp1.fulfill()
            }
            if state == .userHasBeenRevoked {
                exp2.fulfill()
            }
            return Empty().eraseToAnyPublisher()
        }
        checkAuthorizationSpin.effects.append(Feedback<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent>(effect: spyEffectCheckAuthorizationSpin).effect)

        // When: executing the 2 spins
        AnyPublisher.stream(from: checkAuthorizationSpin)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in } )
            .store(in: &self.subscriptions)

        wait(for: [exp1], timeout: 0.5)

        AnyPublisher.stream(from:fetchFeatureSpin)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in } )
            .store(in: &self.subscriptions)

        wait(for: [exp2], timeout: 0.5)

        // Then: the stream of states produced by the spins are the expected one thanks to the propagation of the gear
        XCTAssertEqual(receivedFeatureStates[0], .initial)
        XCTAssertEqual(receivedFeatureStates[1], .unauthorized)
        XCTAssertEqual(receivedCheckAuthorization[0], .initial)
        XCTAssertEqual(receivedCheckAuthorization[1], .authorizationShouldBeChecked)
        XCTAssertEqual(receivedCheckAuthorization[2], .userHasBeenRevoked)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

        let checkAuthorizationSideEffect: (CheckAuthorizationSpinState) -> AnyPublisher<CheckAuthorizationSpinEvent, Never> = { state in
            guard state == .authorizationShouldBeChecked else { return Empty().eraseToAnyPublisher() }
            return Just<CheckAuthorizationSpinEvent>(.revokeUser).eraseToAnyPublisher()
        }

        let attachedCheckAuthorizationFeedback = Feedback<CheckAuthorizationSpinState, CheckAuthorizationSpinEvent>(
            attachedTo: gear,
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

        let fetchFeatureSideEffect: (FetchFeatureSpinState) -> AnyPublisher<FetchFeatureSpinEvent, Never> = { state in
            guard state == .initial else { return Empty().eraseToAnyPublisher() }
            return Just<FetchFeatureSpinEvent>(.userIsNotAuthorized).eraseToAnyPublisher()
        }

        let attachedFetchFeatureFeedback = Feedback<FetchFeatureSpinState, FetchFeatureSpinEvent>(
            attachedTo: gear,
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
