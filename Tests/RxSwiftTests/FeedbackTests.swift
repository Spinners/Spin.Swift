////
////  FeedbackTests.swift
////  
////
////  Created by Thibault Wittemberg on 2019-12-31.
////

import RxBlocking
import RxSwift
@testable import SpinRxSwift
import XCTest

final class FeedbackTests: XCTestCase {

    private let disposeBag = DisposeBag()

    func test_effect_observes_on_current_executer_when_nilExecuter_is_passed_to_initializer() {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with no Executer
        let sut = Feedback(effect: { (inputs: Observable<Int>) -> Observable<String> in
            effectIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }
        })

        // Given: an input stream observed on a dedicated Executer
        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName,
                                                                                         qos: .userInitiated))

        let inputStream = Observable<Int>
            .just(1701)
            .observeOn(inputStreamScheduler)

        // When: executing the feedback
        _ = sut.effect(inputStream).toBlocking().materialize()

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer specified on the inputStream, since no Executer has been
        // given in the Feedback initializer
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_effect_observes_on_an_executer_when_one_is_passed_to_initializer() {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with a dedicated Executer
        let feedbackScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: expectedExecuterName,
                                                                                      qos: .userInitiated))

        let sut = Feedback(effect: { (inputs: Observable<Int>) -> Observable<String> in
            effectIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }
        }, on: feedbackScheduler)

        // Given: an input stream observed on a dedicated Executer
        let inputStreamSchedulerQueueName = "INPUT_STREAM_QUEUE_\(UUID().uuidString)"
        let inputStreamScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: inputStreamSchedulerQueueName,
                                                                                         qos: .userInitiated))

        let inputStream = Observable<Int>
            .just(1701)
            .observeOn(inputStreamScheduler)

        // When: executing the feedback
        _ = sut.effect(inputStream).toBlocking().materialize()

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer given in the Feedback initializer, not on the one defined on
        // the inputStream
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_init_produces_a_non_cancellable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: a effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        let longOperationSchedulerQueueLabel = "LONG_OPERATION_QUEUE_\(UUID().uuidString)"
        let longOperationScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: longOperationSchedulerQueueLabel,
                                                                                           qos: .userInitiated))

        let effect = { (input: Int) -> Observable<String> in
            if input == 1 {
                return Observable<String>.create { (observer) -> Disposable in
                    observer.onNext("\(input)")
                    observer.onCompleted()
                    return Disposables.create()
                }
                .delaySubscription(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .userInitiated))
                .subscribeOn(longOperationScheduler)
            }

            return .just("\(input)")
        }

        // Given: this stream being applied a "continueOnNewState" strategy
        let sut = Feedback(effect: effect, applying: .continueOnNewState).effect

        // When: feeding this effect with 2 events: 1 and 2
        let received = try sut(.from([1, 2])).toBlocking().toArray()

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(received, ["2", "1"])
    }

    func test_init_produces_a_non_failable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        let effect = { (input: Int) -> Observable<String> in
            if input == 1 {
                return .error(NSError(domain: "feedback", code: 0))
            }

            return .just("\(input)")
        }

        // Given: this effect being applied a "continueOnNewState" strategy
        let sut = Feedback(effect: effect, applying: .continueOnNewState).effect

        // When: feeding this effect with 2 events: 1 and 2
        let received = try sut(.from([1, 2])).toBlocking().toArray()

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(received, ["2"])
    }

    func test_init_produces_a_cancellable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        let longOperationSchedulerQueueLabel = "LONG_OPERATION_QUEUE_\(UUID().uuidString)"
        let longOperationScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: longOperationSchedulerQueueLabel,
                                                                                           qos: .userInitiated))

        let effect = { (input: Int) -> Observable<String> in
            if input == 1 {
                return Observable<String>.create { (observer) -> Disposable in
                    observer.onNext("\(input)")
                    observer.onCompleted()
                    return Disposables.create()
                }
                .delaySubscription(.seconds(1), scheduler: SerialDispatchQueueScheduler(qos: .userInitiated))
                .subscribeOn(longOperationScheduler)
            }

            return .just("\(input)")
        }

        // Given: this effect being applied a "cancelOnNewEvent" strategy
        let sut = Feedback(effect: effect, applying: .cancelOnNewState).effect

        // When: feeding this effect with 2 events: 1 and 2
        let received = try sut(.from([1, 2])).toBlocking().toArray()

        // Then: the stream does not wait for the long operation to end before completing, the first operation is cancelled
        // in favor of the immediate one
        XCTAssertEqual(received, ["2"])
    }

    func test_init_produces_a_non_failable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        let effect = { (input: Int) -> Observable<String> in
            if input == 1 {
                return .error(NSError(domain: "feedback", code: 0))
            }

            return .just("\(input)")
        }

        // Given: this effect being applied a "continueOnNewState" strategy
        let sut = Feedback(effect: effect, applying: .cancelOnNewState).effect

        // When: feeding this effect with 2 events: 1 and 2
        let received = try sut(.from([1, 2])).toBlocking().toArray()

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(received, ["2"])
    }

    func test_directEffect_is_used() {
        var effectIsCalled = false

        // Given: a feedback from a directEffect
        let sut = Feedback(directEffect: { (input: Int) -> String in
            effectIsCalled = true
            return "\(input)"
        }, on: nil)

        // When: executing the feedback
        let inputStream = Observable.just(1701)
        _ = sut.effect(inputStream).take(1).toBlocking().materialize()

        // Then: the directEffect is called
        XCTAssertTrue(effectIsCalled)
    }

    func test_effects_are_used() throws {
        var effectAIsCalled = false
        var effectBIsCalled = false

        // Given: a feedback from 2 effects
        let effectA = { (inputs: Observable<Int>) -> Observable<String> in
            effectAIsCalled = true
            return inputs.map { "\($0)" }
        }
        let effectB = { (inputs: Observable<Int>) -> Observable<String> in
            effectBIsCalled = true
            return inputs.map { "\($0)" }
        }

        let sut = Feedback(effects: [effectA, effectB])

        // When: executing the feedback
        let inputStream = Observable.just(1701)
        _ = sut.effect(inputStream).take(1).toBlocking().materialize()

        // Then: the effects are called
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func testFeedback_call_gearSideEffect_and_does_only_trigger_a_feedbackEvent_when_attachment_return_not_nil() {
        let exp = expectation(description: "attach")
        let gear = Gear<Int>()
        var numberOfCallsGearSideEffect = 0
        var receivedEvents = [String]()

        // Given: a feedback attached to a Gear and triggering en event only of the gear event is 1
        let sut = Feedback<Int, String>(attachedTo: gear, propagating: { gearEvent -> String? in
            numberOfCallsGearSideEffect += 1
            if gearEvent == 1 {
                return "event"
            }

            return nil
        })

        // When: executing the feedback
        let inputStream = Observable<Int>.just(1701)
        sut.effect(inputStream)
            .do(onNext: { event in
                receivedEvents.append(event)
                if receivedEvents.count == 1 {
                    exp.fulfill()
                }
            })
            .subscribe()
            .disposed(by: self.disposeBag)

        // When: sending 0 and then 1 as gear event
        gear.eventSubject.accept(0)
        gear.eventSubject.accept(1)

        waitForExpectations(timeout: 0.5)

        // Then: the gear dedicated side effect is called twice
        // Then: the only event triggered by the feedback is the one when attachment is not nil
        XCTAssertEqual(numberOfCallsGearSideEffect, 2)
        XCTAssertEqual(receivedEvents, ["event"])
    }

    func testFeedback_call_gearSideEffect_and_does_only_trigger_a_feedbackEvent_when_catching_expected_event() {
        let exp = expectation(description: "attach")
        let gear = Gear<Int>()
        var receivedEvents = [String]()

        // Given: a feedback attached to a Gear and triggering en event only of the gear event is 1
        let sut = Feedback<Int, String>(attachedTo: gear, catching: 1, emitting: "event")

        // When: executing the feedback
        let inputStream = Observable<Int>.just(1701)
        sut.effect(inputStream)
            .do(onNext: { event in
                receivedEvents.append(event)
                if receivedEvents.count == 1 {
                    exp.fulfill()
                }
            })
            .subscribe()
            .disposed(by: self.disposeBag)

        // When: sending 0 and then 1 as gear event
        gear.eventSubject.accept(0)
        gear.eventSubject.accept(1)

        waitForExpectations(timeout: 0.5)

        // Then: the gear dedicated side effect is called twice
        // Then: the only event triggered by the feedback is the one when attachment is not nil
        XCTAssertEqual(receivedEvents, ["event"])
    }
}
