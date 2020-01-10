//
//  ReactiveViewContextTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-08.
//

import Combine
import ReactiveSwift
import Spin_ReactiveSwift
import XCTest

fileprivate class MockContainer {

    var isRenderCalled = false

    func render(state: String) {
        self.isRenderCalled = true
    }
}

final class ReactiveViewContextTests: XCTestCase {

    private var cancellables = [AnyCancellable]()
    private let disposeBag = CompositeDisposable()

    func test_state_is_updated_when_feeding_the_resulting_feedback_with_an_input_state() throws {
        let exp = expectation(description: "new mutation")
        exp.expectedFulfillmentCount = 2

        var receivedState = ""

        // Given: a ViewContext (with an external rendering function) and its resulting feedback
        let sut = ReactiveViewContext<String, String>(state: "initial")
        let container = MockContainer()
        sut.render(on: container) { $0.render(state:) }
        let feedback = sut.toFeedback()

        sut.$state.sink { state in
            receivedState = state
            exp.fulfill()
        }.store(in: &self.cancellables)

        // When: feeding the resulting feedback with a state input stream
        feedback.feedbackStream(SignalProducer<String, Never>(value: "newState")).start().disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the state is updated in the ViewContext and the external rendering function is called
        XCTAssertEqual(receivedState, "newState")
        XCTAssertTrue(container.isRenderCalled)
    }

    func test_mutation_is_output_by_the_feedback_when_sending_a_mutation_to_the_viewContext() throws {
        let exp = expectation(description: "new mutation")

        var receivedMutation = ""

        // Given: a ViewContext and its resulting feedback
        let sut = ReactiveViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        feedback.feedbackStream(SignalProducer<String, Never>(value: "newState")).startWithValues{ mutation in
            receivedMutation = mutation
            exp.fulfill()
        }.disposed(by: self.disposeBag)

        // When: sending a mutation to the viewContext
        sut.perform("newMutation")
        waitForExpectations(timeout: 5)

        // Then: the resulting feedback outputs the mutation
        XCTAssertEqual(receivedMutation, "newMutation")
    }
}
