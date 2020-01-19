//
//  CombineViewContextTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-08.
//

import Combine
import Spin_Combine
import XCTest

fileprivate class MockContainer {

    var isRenderCalled = false

    func render(state: String) {
        self.isRenderCalled = true
    }
}

final class CombineViewContextTests: XCTestCase {

    private var disposeBag = [AnyCancellable]()

    func test_state_is_updated_when_feeding_the_resulting_feedback_with_an_input_state() throws {
        let exp = expectation(description: "new event")
        exp.expectedFulfillmentCount = 2

        var receivedState = ""

        // Given: a ViewContext (with an external rendering function) and its resulting feedback
        let sut = CombineViewContext<String, String>(state: "initial")
        let container = MockContainer()
        sut.render(on: container) { $0.render(state:) }

        // Make sure the render function is called directly after being set on the containe
        XCTAssertTrue(container.isRenderCalled)
        container.isRenderCalled = false

        let feedback = sut.toFeedback()

        sut.$state.sink { state in
            receivedState = state
            exp.fulfill()
        }.disposed(by: &self.disposeBag)

        // When: feeding the resulting feedback with a state input stream
        let subject = PassthroughSubject<String, Never>()
        feedback.feedbackStream(Just<String>("newState").eraseToAnyPublisher()).subscribe(subject).disposed(by: &self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the state is updated in the ViewContext and the external rendering function is called
        XCTAssertEqual(receivedState, "newState")
        XCTAssertTrue(container.isRenderCalled)
    }

    func test_event_is_output_by_the_feedback_when_sending_a_event_to_the_viewContext() throws {
        let exp = expectation(description: "new event")

        var receivedEvent = ""

        // Given: a ViewContext and its resulting feedback
        let sut = CombineViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        feedback.feedbackStream(Just<String>("newState").eraseToAnyPublisher()).sink { event in
            receivedEvent = event
            exp.fulfill()
        }.disposed(by: &self.disposeBag)

        // When: sending a event to the viewContext
        sut.emit("newEvent")
        waitForExpectations(timeout: 5)

        // Then: the resulting feedback outputs the event
        XCTAssertEqual(receivedEvent, "newEvent")
    }
}
