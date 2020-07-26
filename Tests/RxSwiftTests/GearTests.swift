//
//  GearTests.swift
//
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

@testable import SpinRxSwift
import RxSwift
import XCTest

final class GearTests: XCTestCase {
    private var subscriptions = DisposeBag()

    func testPropagate_trigger_eventStream() throws {
        let exp = expectation(description: "Gear")
        let expectedValue = 1
        var receivedValue: Int?

        // Given: a gear
        let sut = Gear<Int>()

        sut
            .eventStream
            .subscribe(onNext: { value in
                receivedValue = value
                exp.fulfill()
        }).disposed(by: self.subscriptions)

        // When: propagating en event
        sut.propagate(event: 1)

        waitForExpectations(timeout: 0.5)

        // Then: the eventStream outputs the expected value
        XCTAssertEqual(receivedValue, expectedValue)
    }
}
