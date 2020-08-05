//
//  GearTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

@testable import SpinReactiveSwift
import ReactiveSwift
import XCTest

final class GearTests: XCTestCase {
    private var disposables = CompositeDisposable()

    func testPropagate_trigger_eventStream() throws {
        let exp = expectation(description: "Gear")
        let expectedValue = 1
        var receivedValue: Int?

        // Given: a gear
        let sut = Gear<Int>()

        sut
            .eventStream
            .startWithValues { value in
                receivedValue = value
                exp.fulfill()
        }
        .add(to: self.disposables)

        // When: propagating en event
        sut.propagate(event: 1)

        waitForExpectations(timeout: 0.5)

        // Then: the eventStream outputs the expected value
        XCTAssertEqual(receivedValue, expectedValue)
    }
}
