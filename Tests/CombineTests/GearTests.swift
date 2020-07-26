//
//  GearTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

@testable import SpinCombine
import Combine
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class GearTests: XCTestCase {
    private var subscriptions = [AnyCancellable]()

    func testPropagate_trigger_eventStream() throws {
        let exp = expectation(description: "Gear")
        let expectedValue = 1
        var receivedValue: Int?

        // Given: a gear
        let sut = Gear<Int>()

        sut
            .eventStream
            .sink { value in
                receivedValue = value
                exp.fulfill()
        }.store(in: &self.subscriptions)

        // When: propagating en event
        sut.propagate(event: 1)

        waitForExpectations(timeout: 0.5)

        // Then: the eventStream outputs the expected value
        XCTAssertEqual(receivedValue, expectedValue)
    }
}
