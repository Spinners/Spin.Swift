//
//  RxViewContextTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-08.
//

import Combine
import RxSwift
import Spin_RxSwift
import XCTest

fileprivate class MockContainer {

    var isRenderCalled = false

    func render(state: String) {
        self.isRenderCalled = true
    }
}

final class RxViewContextTests: XCTestCase {

    private var cancellables = [AnyCancellable]()
    private let disposeBag = DisposeBag()

    func test_state_is_updated_when_feeding_the_resulting_feedback_with_an_input_state() throws {
        let exp = expectation(description: "new event")
        exp.expectedFulfillmentCount = 2

        var receivedState = ""

        // Given: a ViewContext (with an external rendering function) and its resulting feedback
        let sut = RxViewContext<String, String>(state: "initial")
        let container = MockContainer()
        sut.render(on: container) { $0.render(state:) }

        // Make sure the render function is called directly after being set on the containe
        XCTAssertTrue(container.isRenderCalled)
        container.isRenderCalled = false

        let feedback = sut.toFeedback()

        sut.$state.sink { state in
            receivedState = state
            exp.fulfill()
        }.store(in: &self.cancellables)

        // When: feeding the resulting feedback with a state input stream
        feedback.feedbackStream(.just("newState")).subscribe().disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: the state is updated in the ViewContext and the external rendering function is called
        XCTAssertEqual(receivedState, "newState")
        XCTAssertTrue(container.isRenderCalled)
    }

    func test_event_is_output_by_the_feedback_when_sending_a_event_to_the_viewContext() throws {
        let exp = expectation(description: "new event")

        var receivedEvent = ""

        // Given: a ViewContext and its resulting feedback
        let sut = RxViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        feedback.feedbackStream(.just("newState")).subscribe(onNext: { event in
            receivedEvent = event
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        // When: sending a event to the viewContext
        sut.emit("newEvent")
        waitForExpectations(timeout: 5)

        // Then: the resulting feedback outputs the event
        XCTAssertEqual(receivedEvent, "newEvent")
    }

    func test_binding_make_the_viewContext_emit_an_event_when_the_binding_is_mutated() {
        let exp = expectation(description: "new event")
        var receivedEvent = ""

        // Given: a ViewContext and its resulting feedback
        let sut = RxViewContext<String, String>(state: "initial")
        let feedback = sut.toFeedback()

        // Given: a Binding on the \.count State KeyPath
        let binding = sut.binding(for: \.count, event: { "\($0)" })

        // Then: the "get" side of the Binding gives the actuel state size in terms of string count ("initialState" -> 7 chars)
        XCTAssertEqual(binding.wrappedValue, 7)
        
        feedback.feedbackStream(.just("newState")).subscribe(onNext: { event in
            receivedEvent = event
            exp.fulfill()
        }).disposed(by: self.disposeBag)

        // When: "setting" the Binding to a new count value
        binding.wrappedValue = 16

        waitForExpectations(timeout: 5)

        // Then: an Event is emitted with the new count value
        XCTAssertEqual(receivedEvent, "16")
    }
}
