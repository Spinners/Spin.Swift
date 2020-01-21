//
//  CombineFeedback.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Spin_Combine
import Spin_Swift
import XCTest

final class CombineFeedbackTests: XCTestCase {
    func test_feedbackStream_observes_on_current_executer_when_nilExecuter_is_passed_to_initializer() throws {
        var feedbackIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with no Executer
        let nilExecuter: DispatchQueue? = nil
        let sut = CombineFeedback(effect: { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            feedbackIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }.eraseToAnyPublisher()
        }, on: nilExecuter?.eraseToAnyScheduler())

        // Given: an input stream observed on a dedicated Executer
        let inputStream = Just<Int>(1701)
            .receive(on: DispatchQueue(label: expectedExecuterName, qos: .userInitiated))
            .eraseToAnyPublisher()

        // When: executing the feedback
        let recorder = sut.effect(inputStream).record()
        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the feedback is called
        // Then: the feedback happens on the dedicated Executer specified on the inputStream, since no Executer has been given
        // in the Feedback initializer
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_feedbackStream_observes_on_an_executer_when_one_is_passed_to_initializer() throws {
        var feedbackIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with a dedicated Executer
        let sut = CombineFeedback(effect: { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            feedbackIsCalled = true
            return inputs.map {
                receivedExecuterName = DispatchQueue.currentLabel
                return "\($0)"
            }.eraseToAnyPublisher()
        }, on: DispatchQueue(label: expectedExecuterName, qos: .userInitiated).eraseToAnyScheduler())

        // Given: an input stream observed on a dedicated Executer
        let inputStream = Just<Int>(1701)
            .receive(on: DispatchQueue(label: "FEEDBACK_QUEUE_\(UUID().uuidString)", qos: .userInitiated))
            .eraseToAnyPublisher()

        // When: executing the feedback
        let recorder = sut.effect(inputStream).record()
        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the feedback is called
        // Then: the feedback happens on the dedicated Executer given in the Feedback initializer, not on the one defined
        // on the inputStream
        XCTAssertTrue(feedbackIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_make_produces_a_non_cancellable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: a stream that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationStream(outputing: Int) -> AnyPublisher<String, Never> {
            return Future<String, Never> { (observer) in
                sleep(1)
                observer(.success("\(outputing)"))
            }.eraseToAnyPublisher()
        }

        let longOperationQueue = DispatchQueue(label: "FEEDBACK_QUEUE_\(UUID().uuidString)", qos: .background)

        let stream = { (input: Int) -> AnyPublisher<String, Never> in
            if input == 1 {
                return Just<Void>(())
                    .receive(on: longOperationQueue)
                    .flatMap { _ in return makeLongOperationStream(outputing: input) }
                    .eraseToAnyPublisher()
            }

            return Just<String>("\(input)").eraseToAnyPublisher()
        }

        // Given: this stream being applied a "continueOnNewEvent" strategy
        let sut = DispatchQueueCombineFeedback<Int, String>.make(from: stream, applying: .continueOnNewEvent)

        // When: feeding this stream with 2 events: 1 and 2
        let recorder = sut([1, 2].publisher.eraseToAnyPublisher()).record()
        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(receivedElements, ["2", "1"])
    }

    func test_make_produces_a_cancellable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: a stream that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationStream(outputing: Int) -> AnyPublisher<String, Never> {
            return Future<String, Never> { (observer) in
                sleep(1)
                observer(.success("\(outputing)"))
            }.eraseToAnyPublisher()
        }

        let longOperationQueue = DispatchQueue(label: "FEEDBACK_QUEUE_\(UUID().uuidString)", qos: .background)

        let stream = { (input: Int) -> AnyPublisher<String, Never> in
            if input == 1 {
                return Just<Void>(())
                    .receive(on: longOperationQueue)
                    .flatMap { _ in return makeLongOperationStream(outputing: input) }
                    .eraseToAnyPublisher()
            }

            return Just<String>("\(input)").eraseToAnyPublisher()
        }

        // Given: this stream being applied a "cancelOnNewEvent" strategy
        let sut = DispatchQueueCombineFeedback<Int, String>.make(from: stream, applying: .cancelOnNewEvent)

        // When: feeding this stream with 2 events: 1 and 2
        let recorder = sut([1, 2].publisher.eraseToAnyPublisher()).record()
        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the stream does not wait for the long operation to end before completing, the first operation is cancelled in favor
        // of the immediate one
        XCTAssertEqual(receivedElements, ["2"])
    }

    func test_initialize_with_two_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 2 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false

        let effectA: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectAIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectB: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectBIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }

        let sourceFeedbackA = DispatchQueueCombineFeedback(effect: effectA)
        let sourceFeedbackB = DispatchQueueCombineFeedback(effect: effectB)

        // When: instantiating the feedback with already existing feedbacks
        // When: executing the feedback
        let sut = DispatchQueueCombineFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB)
        let recorder = sut.effect(Just(0).eraseToAnyPublisher()).collect(2).record()
        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }

    func test_initialize_with_three_feedbacks_executes_the_original_feedbackFunctions() throws {
        // Given: 3 feedbacks based on a Stream<State> -> Stream<Event>
        var effectAIsCalled = false
        var effectBIsCalled = false
        var effectCIsCalled = false

        let effectA: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectAIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectB: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectBIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectC: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectCIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }

        let sourceFeedbackA = DispatchQueueCombineFeedback(effect: effectA)
        let sourceFeedbackB = DispatchQueueCombineFeedback(effect: effectB)
        let sourceFeedbackC = DispatchQueueCombineFeedback(effect: effectC)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = DispatchQueueCombineFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB, sourceFeedbackC)
        let recorder = sut.effect(Just(0).eraseToAnyPublisher()).collect(3).record()
        _ = try wait(for: recorder.elements, timeout: 5)

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

        let effectA: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectAIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectB: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectBIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectC: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectCIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectD: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectDIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }

        let sourceFeedbackA = DispatchQueueCombineFeedback(effect: effectA)
        let sourceFeedbackB = DispatchQueueCombineFeedback(effect: effectB)
        let sourceFeedbackC = DispatchQueueCombineFeedback(effect: effectC)
        let sourceFeedbackD = DispatchQueueCombineFeedback(effect: effectD)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = DispatchQueueCombineFeedback(feedbacks: sourceFeedbackA, sourceFeedbackB, sourceFeedbackC, sourceFeedbackD)
        let recorder = sut.effect(Just(0).eraseToAnyPublisher()).collect(4).record()
        _ = try wait(for: recorder.elements, timeout: 5)

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

        let effectA: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectAIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectB: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectBIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectC: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectCIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectD: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectDIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectE: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectEIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }

        let sourceFeedbackA = DispatchQueueCombineFeedback(effect: effectA)
        let sourceFeedbackB = DispatchQueueCombineFeedback(effect: effectB)
        let sourceFeedbackC = DispatchQueueCombineFeedback(effect: effectC)
        let sourceFeedbackD = DispatchQueueCombineFeedback(effect: effectD)
        let sourceFeedbackE = DispatchQueueCombineFeedback(effect: effectE)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = DispatchQueueCombineFeedback(feedbacks: sourceFeedbackA,
                                               sourceFeedbackB,
                                               sourceFeedbackC,
                                               sourceFeedbackD,
                                               sourceFeedbackE)
        let recorder = sut.effect(Just(0).eraseToAnyPublisher()).collect(5).record()
        _ = try wait(for: recorder.elements, timeout: 5)

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

        let effectA: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectAIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectB: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectBIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectC: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectCIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectD: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectDIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }
        let effectE: (Int) -> AnyPublisher<Int, Never> = { states -> AnyPublisher<Int, Never> in
            effectEIsCalled = true
            return Just(0).eraseToAnyPublisher()
        }

        let sourceFeedbackA = DispatchQueueCombineFeedback(effect: effectA)
        let sourceFeedbackB = DispatchQueueCombineFeedback(effect: effectB)
        let sourceFeedbackC = DispatchQueueCombineFeedback(effect: effectC)
        let sourceFeedbackD = DispatchQueueCombineFeedback(effect: effectD)
        let sourceFeedbackE = DispatchQueueCombineFeedback(effect: effectE)

        // When: instantiating the feedback with already existing feedbacks with function builder
        // When: executing the feedback
        let sut = DispatchQueueCombineFeedback(feedbacks: [sourceFeedbackA,
                                               sourceFeedbackB,
                                               sourceFeedbackC,
                                               sourceFeedbackD,
                                               sourceFeedbackE])
        let recorder = sut.effect(Just(0).eraseToAnyPublisher()).collect(5).record()
        _ = try wait(for: recorder.elements, timeout: 5)

        // Then: the original feedback streams are preserved
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
        XCTAssertTrue(effectCIsCalled)
        XCTAssertTrue(effectDIsCalled)
        XCTAssertTrue(effectEIsCalled)
    }
}
