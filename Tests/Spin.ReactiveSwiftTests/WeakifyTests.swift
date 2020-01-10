//
//  WeakifyTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-09.
//

@testable import Spin_ReactiveSwift
import XCTest

fileprivate class MockContainer {

    private let exp: XCTestExpectation

    init(exp: XCTestExpectation) {
        self.exp = exp
    }

    func captureFunction(input: String) {
        print(input)
    }

    deinit {
        exp.fulfill()
    }
}

final class WeakifyTests: XCTestCase {

    func test_weakify_unretain_container() {

        let exp = expectation(description: "weakify")

        // Given: a container
        // When: weakifying a function belonging to that container
        let weakifiedFunction = weakify(container: MockContainer(exp: exp)) { $0.captureFunction }

        // Then: the container is deinit once its instance is no more referenced
        waitForExpectations(timeout: 5)
        weakifiedFunction("input")
    }

}
