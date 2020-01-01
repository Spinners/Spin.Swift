//
//  Observable+ReactiveStreamTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxBlocking
import RxRelay
import RxSwift
import Spin_RxSwift
import XCTest

final class Observable_ReactiveStreamTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_reactive_stream_is_subscribed_when_spin_is_called() {

        // Given: a reactive stream
        let exp = expectation(description: "spin expectation")
        var receivedValue = 0
        let sut = Observable<Int>.just(1701)

        // When: spinning this reactive stream
        sut
            .do(onNext: { value in
                receivedValue = value
                exp.fulfill()
            })
            .spin()
            .disposed(by: self.disposeBag)

        waitForExpectations(timeout: 5)

        // Then: The stream is executed and the value is fired
        XCTAssertEqual(receivedValue, 1701)
    }

    func test_reactive_stream_is_subscribed_after_a_trigger_when_spin_is_called() {
        // Given: a reactive stream
        let exp = expectation(description: "spin expectation")
        let sut = Observable<Int>.just(1701)
        let trigger = PublishRelay<Void>()
        var streamTime = 0.0
        var triggerTime = 0.0

        // When: spinning this reactive stream after a trigger
        sut
            .do(onNext: { value in
                streamTime = Date().timeIntervalSince1970
                exp.fulfill()
            })
            .spin(after: trigger.do(onNext: { _ in triggerTime = Date().timeIntervalSince1970 }).asObservable())
            .disposed(by: self.disposeBag)

        trigger.accept(())

        waitForExpectations(timeout: 5)

        // Then: The stream is executed after the trigger has fired an event
        XCTAssert(triggerTime < streamTime)
    }

    func test_reactive_stream_makes_an_empty_stream_when_emptyStream_is_called() {
        // Given: an empty reactive stream
        let sut = Observable<Int>.emptyStream()

        // When: subscribing to it
        let events = sut.toBlocking().materialize()

        // Then: the stream directly completes without emitting events
        XCTAssertEqual(events, MaterializedSequenceResult<Int>.completed(elements: []))
    }
}
