//
//  SpinDefinitionTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Spin_Swift
import XCTest

final class SpinDefinitionTests: XCTestCase {
    func test_toReactiveStream_makes_stream_based_on_the_provided_feedback_and_reducer() {
        // Given: a SpinDefinition
        let sut = MockSpinDefinition()

        // When: requesting the stream resulting in the Spin building
        _ = sut.toReactiveStream()

        // Then: the reducing process has been called
        XCTAssertTrue(sut.feedbackIsCalled)
        XCTAssertTrue(sut.reducerIsCalled)
    }

    func test_spin_makes_stream_based_on_the_provided_feedback_and_reducer() {
        // Given: a SpinDefinition
        let sut = MockSpinDefinition()

        // When: requesting the stream resulting in the Spin building
        _ = sut.spin()

        // Then: the reducing process has been called
        XCTAssertTrue(sut.feedbackIsCalled)
        XCTAssertTrue(sut.reducerIsCalled)
    }
}
