//
//  SignalProducer+DeferredTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
@testable import SpinReactiveSwift
import XCTest

final class SignalProducer_DeferredTests: XCTestCase {
    func test_deferred_waits_for_subscription_to_build_the_signalProducer() throws {
        // Given: a factory of a SignalProducer using a deferred statement
        var isSignalProducerBuilt = false

        func makeSignalProducer() -> SignalProducer<Int, Never> {
            return SignalProducer.deferred { () -> SignalProducer<Int, Never> in
                isSignalProducerBuilt = true
                return SignalProducer<Int, Never>(value: 1701)
            }
        }

        // When: calling that factory and building the SignalProducer
        let sut = makeSignalProducer()

        // Then: the SignalProducer is not yet built
        XCTAssertFalse(isSignalProducerBuilt)

        // When: subscribing to the SignalProducer
        _ = try sut.take(first: 1).collect().first()?.get()

        // Then: the underlying SignalProducet is built
        XCTAssertTrue(isSignalProducerBuilt)
    }
}
