//
//  CombineViewContextTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-08.
//

import Combine
import Spin_Combine
import XCTest

final class CombineViewContextTests: XCTestCase {

    private var disposeBag = [AnyCancellable]()

    func test_state_is_updated_when_feeding_the_resulting_feedback_with_an_input_state() throws {
        let exp = expectation(description: "new mutation")
        exp.expectedFulfillmentCount = 2

        var receivedState = ""

        // Given: a ViewContext and its resulting feedback
        let sut = CombineViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        sut.$state.sink { state in
            receivedState = state
            exp.fulfill()
        }.disposed(by: &self.disposeBag)

        // When: feeding the resulting feedback with a state input stream
        let subject = PassthroughSubject<String, Never>()
        feedback.feedbackStream(Just<String>("newState").eraseToAnyPublisher()).subscribe(subject).disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the state is updated in the ViewContext
        XCTAssertEqual(receivedState, "newState")
    }

    func test_mutation_is_output_by_the_feedback_when_sending_a_mutation_to_the_viewContext() throws {
        let exp = expectation(description: "new mutation")

        var receivedMutation = ""

        // Given: a ViewContext and its resulting feedback
        let sut = CombineViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        feedback.feedbackStream(Just<String>("newState").eraseToAnyPublisher()).sink { mutation in
            receivedMutation = mutation
            exp.fulfill()
        }.disposed(by: &self.disposeBag)

        // When: sending a mutation to the viewContext
        sut.send(mutation: "newMutation")
        waitForExpectations(timeout: 5)

        // Then: the resulting feedback outputs the mutation
        XCTAssertEqual(receivedMutation, "newMutation")
    }
}
