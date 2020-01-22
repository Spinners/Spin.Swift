//
//  SpinTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-22.
//

import XCTest

final class SpinTests: XCTestCase {
    func test_toReactiveStream_gives_the_stream_holded_by_the_spin() {
        // Given: a spin initialized with a reactive stream
        let expectedState = MockState(subState: 10)
        let sut = MockSpin(stream: MockStream<MockState>(value: expectedState))

        // When: getting the underlying reactive stream
        // Then: the stream is the one from the Spin
        XCTAssertEqual(sut.toReactiveStream().value, expectedState)
    }
}
