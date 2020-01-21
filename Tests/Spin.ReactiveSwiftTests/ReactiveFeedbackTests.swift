//
//  ReactiveFeedbackTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_ReactiveSwift
import XCTest

final class ReactiveFeedbackTests: XCTestCase {
    func test_feedbackStream_observes_on_current_executer_when_nilExecuter_is_passed_to_initializer() {
        var feedbackIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with no Executer
        let sut = ReactiveFeedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            feedbackIsCalled = true
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

        // Then: the feedback is called
        // Then: the feedback happens on the dedicated Executer specified on the inputStream, since no Executer has been given
        // in the Feedback initializer
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_feedbackStream_observes_on_an_executer_when_one_is_passed_to_initializer() {
        var feedbackIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with a dedicated Executer
        let sut = ReactiveFeedback(effect: { (inputs: SignalProducer<Int, Never>) -> SignalProducer<String, Never> in
            feedbackIsCalled = true
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

        // Then: the feedback is called
        // Then: the feedback happens on the dedicated Executer given in the Feedback initializer, not on the one defined
        // on the inputStream
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_make_produces_a_non_cancellable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: a stream that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationStream(outputing: Int) -> SignalProducer<String, Never> {
            return SignalProducer<String, Never> { (observer, lifetime) in
                sleep(1)
                observer.send(value: "\(outputing)")
                observer.sendCompleted()
            }
        }

        let stream = { (input: Int) -> SignalProducer<String, Never> in
            if input == 1 {
                return SignalProducer<Void, Never>(value: ())
                    .observe(on: QueueScheduler(qos: .background, name: "FEEDBACK_QUEUE_\(UUID().uuidString)"))
                    .flatMap(.concat) { _ -> SignalProducer<String, Never> in
                        return makeLongOperationStream(outputing: input)
                }
            }

            return SignalProducer<String, Never>(value: "\(input)")
        }

        // Given: this stream being applied a "continueOnNewEvent" strategy
        let sut = ReactiveFeedback.make(from: stream, applying: .continueOnNewEvent)

        // When: feeding this stream with 2 events: 1 and 2
        let received = try sut(SignalProducer<Int, Never>([1, 2])).take(first: 2).collect().first()!.get()

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(received, ["2", "1"])
    }

    func test_make_produces_a_cancellable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: a stream that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationStream(outputing: Int) -> SignalProducer<String, Never> {
            return SignalProducer<String, Never> { (observer, lifetime) in
                sleep(1)
                observer.send(value: "\(outputing)")
                observer.sendCompleted()
            }
        }

        let stream = { (input: Int) -> SignalProducer<String, Never> in
            if input == 1 {
                return SignalProducer<Void, Never>(value: ())
                    .observe(on: QueueScheduler(qos: .background, name: "FEEDBACK_QUEUE_\(UUID().uuidString)"))
                    .flatMap(.concat) { _ -> SignalProducer<String, Never> in
                        return makeLongOperationStream(outputing: input)
                }
            }

            return SignalProducer<String, Never>(value: "\(input)")
        }

        // Given: this stream being applied a "cancelOnNewEvent" strategy
        let sut = ReactiveFeedback.make(from: stream, applying: .cancelOnNewEvent)

        // When: feeding this stream with 2 events: 1 and 2
        let received = try sut(SignalProducer<Int, Never>([1, 2])).take(first: 2).collect().first()!.get()

        // Then: the stream does not wait for the long operation to end before completing, the first operation is cancelled
        // in favor of the immediate one
        XCTAssertEqual(received, ["2"])
    }

    func test_initialize_with_two_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 2 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectA: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectAIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectB: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectBIsCalled = true
            return SignalProducer(value: 0)
        }

        let sourceFeedbackA = ReactiveFeedback(effect: effectA)
        let sourceFeedbackB = ReactiveFeedback(effect: effectB)

        // When: instantiating the feedback with already existing feedbacks
        // When: executing the feedback
        let sut = ReactiveFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB)
        _ = try sut.effect(SignalProducer(value: 0)).take(first: 2).collect().single()?.get()

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_three_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 3 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

        let effectA: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectAIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectB: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectBIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectC: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectCIsCalled = true
            return SignalProducer(value: 0)
        }

        let sourceFeedbackA = ReactiveFeedback(effect: effectA)
        let sourceFeedbackB = ReactiveFeedback(effect: effectB)
        let sourceFeedbackC = ReactiveFeedback(effect: effectC)

        // When: instantiating the feedback with already existing feedbacks
        // When: executing the feedback
        let sut = ReactiveFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB, sourceFeedbackC)
        _ = try sut.effect(SignalProducer(value: 0)).take(first: 3).collect().single()?.get()

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
    }

    func test_initialize_with_four_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 4 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false

        let effectA: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectAIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectB: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectBIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectC: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectCIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectD: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectDIsCalled = true
            return SignalProducer(value: 0)
        }

        let sourceFeedbackA = ReactiveFeedback(effect: effectA)
        let sourceFeedbackB = ReactiveFeedback(effect: effectB)
        let sourceFeedbackC = ReactiveFeedback(effect: effectC)
        let sourceFeedbackD = ReactiveFeedback(effect: effectD)

        // When: instantiating the feedback with already existing feedbacks
        // When: executing the feedback
        let sut = ReactiveFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB, sourceFeedbackC, sourceFeedbackD)
        _ = try sut.effect(SignalProducer(value: 0)).take(first: 4).collect().single()?.get()

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
    }

    func test_initialize_with_five_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 5 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var effectEIsCalled = false

        let effectA: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectAIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectB: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectBIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectC: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectCIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectD: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectDIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectE: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectEIsCalled = true
            return SignalProducer(value: 0)
        }

        let sourceFeedbackA = ReactiveFeedback(effect: effectA)
        let sourceFeedbackB = ReactiveFeedback(effect: effectB)
        let sourceFeedbackC = ReactiveFeedback(effect: effectC)
        let sourceFeedbackD = ReactiveFeedback(effect: effectD)
        let sourceFeedbackE = ReactiveFeedback(effect: effectE)

        // When: instantiating the feedback with already existing feedbacks
        // When: executing the feedback
        let sut = ReactiveFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB, sourceFeedbackC, sourceFeedbackD, sourceFeedbackE)
        _ = try sut.effect(SignalProducer(value: 0)).take(first: 5).collect().single()?.get()

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }

    func test_initialize_with_an_array_of_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 5 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false
        var effectDIsCalled = false
        var effectEIsCalled = false

        let effectA: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectAIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectB: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectBIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectC: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectCIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectD: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectDIsCalled = true
            return SignalProducer(value: 0)
        }
        let effectE: (Int) -> SignalProducer<Int, Never> = { states -> SignalProducer<Int, Never> in
            effectEIsCalled = true
            return SignalProducer(value: 0)
        }

        let sourceFeedbackA = ReactiveFeedback(effect: effectA)
        let sourceFeedbackB = ReactiveFeedback(effect: effectB)
        let sourceFeedbackC = ReactiveFeedback(effect: effectC)
        let sourceFeedbackD = ReactiveFeedback(effect: effectD)
        let sourceFeedbackE = ReactiveFeedback(effect: effectE)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = ReactiveFeedback(feedbacks: [sourceFeedbackA,
                                               sourceFeedbackB,
                                               sourceFeedbackC,
                                               sourceFeedbackD,
                                               sourceFeedbackE])
        _ = try sut.effect(SignalProducer(value: 0)).take(first: 5).collect().single()?.get()

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }
}
