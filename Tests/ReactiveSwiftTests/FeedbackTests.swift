//
//  FeedbackTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
@testable import SpinReactiveSwift
import XCTest

private class SpyGear: Gear<Int> {
    func finishEventStream() {
        self.eventsObserver.sendCompleted()
    }
}

final class FeedbackTests: XCTestCase {

    private let disposeBag = CompositeDisposable()

    func test_effect_observes_on_current_executer_when_nilExecuter_is_passed_to_initializer() {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with no Executer
        let sut = Feedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            effectIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }
        })

        // Given: an input stream observed on a dedicated Executer
        let inputStream = SignalProducer<Int, Never>(value: 1701)
            .observe(on: QueueScheduler(qos: .userInitiated, name: expectedExecuterName))

        // When: executing the feedback
        _ = sut.effect(inputStream).take(first: 1).collect().first()

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer specified on the inputStream, since no Executer has been given
        // in the Feedback initializer
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_effect_observes_on_an_executer_when_one_is_passed_to_initializer() {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with a dedicated Executer
        let sut = Feedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            effectIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }
        }, on: QueueScheduler(qos: .userInitiated, name: expectedExecuterName))

        // Given: an input stream observed on a dedicated Executer
        let inputStream = SignalProducer<Int, Never>(value: 1701)
            .observe(on: QueueScheduler(qos: .userInitiated, name: "FEEDBACK_QUEUE_\(UUID().uuidString)"))

        // When: executing the feedback
        _ = sut.effect(inputStream).take(first: 1).first()

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer given in the Feedback initializer, not on the one defined
        // on the inputStream
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_init_produces_a_non_cancellable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationEffect(outputing: Int) -> SignalProducer<String, Never> {
            return SignalProducer<String, Never> { (observer, lifetime) in
                sleep(1)
                observer.send(value: "\(outputing)")
                observer.sendCompleted()
            }
        }

        let effect = { (input: Int) -> SignalProducer<String, Never> in
            if input == 1 {
                return SignalProducer<Void, Never>(value: ())
                    .observe(on: QueueScheduler(qos: .background, name: "FEEDBACK_QUEUE_\(UUID().uuidString)"))
                    .flatMap(.concat) { _ -> SignalProducer<String, Never> in
                        return makeLongOperationEffect(outputing: input)
                }
            }

            return SignalProducer<String, Never>(value: "\(input)")
        }

        // Given: this effect being applied a "continueOnNewState" strategy
        let sut = Feedback(effect: effect, applying: .continueOnNewState).effect

        // When: feeding this effect with 2 events: 1 and 2
        let received = try sut(SignalProducer<Int, Never>([1, 2])).take(first: 2).collect().first()!.get()

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(received, ["2", "1"])
    }

    func test_init_produces_a_cancellable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationEffect(outputing: Int) -> SignalProducer<String, Never> {
            return SignalProducer<String, Never> { (observer, lifetime) in
                sleep(1)
                observer.send(value: "\(outputing)")
                observer.sendCompleted()
            }
        }

        let effect = { (input: Int) -> SignalProducer<String, Never> in
            if input == 1 {
                return SignalProducer<Void, Never>(value: ())
                    .observe(on: QueueScheduler(qos: .background, name: "FEEDBACK_QUEUE_\(UUID().uuidString)"))
                    .flatMap(.concat) { _ -> SignalProducer<String, Never> in
                        return makeLongOperationEffect(outputing: input)
                }
            }

            return SignalProducer<String, Never>(value: "\(input)")
        }

        // Given: this effect being applied a "cancelOnNewState" strategy
        let sut = Feedback(effect: effect, applying: .cancelOnNewState).effect

        // When: effect this stream with 2 events: 1 and 2
        let received = try sut(SignalProducer<Int, Never>([1, 2])).take(first: 2).collect().first()!.get()

        // Then: the stream does not wait for the long operation to end before completing, the first operation is cancelled
        // in favor of the immediate one
        XCTAssertEqual(received, ["2"])
    }

    func test_directEffect_is_used() throws {
        var effectIsCalled = false

        // Given: a feedback from a directEffect
        let sut = Feedback(directEffect: { (input: Int) -> String in
            effectIsCalled = true
            return "\(input)"
        }, on: nil)

        // When: executing the feedback
        let inputStream = SignalProducer<Int, Never>(value: 1701)
        _ = try sut.effect(inputStream).take(first: 1).collect().first()!.get()

        // Then: the directEffect is called
        XCTAssertTrue(effectIsCalled)
    }

    func test_effects_are_used() throws {
        var effectAIsCalled = false
        var effectBIsCalled = false

        // Given: a feedback from 2 effects
        let effectA = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            effectAIsCalled = true
            return inputs.map { "\($0)" }
        }
        let effectB = { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            effectBIsCalled = true
            return inputs.map { "\($0)" }
        }

        let sut = Feedback(effects: [effectA, effectB])

        // When: executing the feedback
        let inputStream = SignalProducer<Int, Never>(value: 1701)
        _ = try sut.effect(inputStream).take(first: 1).collect().first()!.get()

        // Then: the effects are called
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func testFeedback_call_gearSideEffect_and_does_only_trigger_a_feedbackEvent_when_attachment_return_not_nil() {
        let exp = expectation(description: "attach")
        let spyGear = SpyGear()
        var numberOfCallsGearSideEffect = 0
        var receivedEvents = [String]()

        // Given: a feedback attached to a Gear and triggering en event only of the gear event is 1
        let sut = Feedback<Int, String>(attachTo: spyGear, propagating: { gearEvent -> String? in
            numberOfCallsGearSideEffect += 1
            if gearEvent == 1 {
                return "event"
            }

            return nil
        })

        // When: executing the feedback
        let inputStream = SignalProducer<Int, Never>(value: 1701)
        sut.effect(inputStream)
            .collect()
            .startWithValues({ events in
                receivedEvents = events
                exp.fulfill()
            })
            .disposed(by: self.disposeBag)

        // When: sending 0 and then 1 as gear event
        spyGear.eventsObserver.send(value: 0)
        spyGear.eventsObserver.send(value: 1)
        spyGear.finishEventStream()

        waitForExpectations(timeout: 0.5)

        // Then: the gear dedicated side effect is called twice
        // Then: the only event triggered by the feedback is the one when attachment is not nil
        XCTAssertEqual(numberOfCallsGearSideEffect, 2)
        XCTAssertEqual(receivedEvents, ["event"])
    }
}
