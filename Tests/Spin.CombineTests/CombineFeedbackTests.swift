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

    func test_effect_observes_on_current_executer_when_nilExecuter_is_passed_to_initializer() throws {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with no Executer
        let nilExecuter: DispatchQueue? = nil
        let sut = CombineFeedback(effect: { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            effectIsCalled = true
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

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer specified in the inputStream, since no Executer has been given
        // in the Feedback initializer
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_effect_observes_on_an_executer_when_one_is_passed_to_initializer() throws {
        var effectIsCalled = false
        var receivedExecuterName = ""
        let expectedExecuterName = "FEEDBACK_QUEUE_\(UUID().uuidString)"

        // Given: a feedback with a dedicated Executer
        let sut = CombineFeedback(effect: { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            effectIsCalled = true
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

        // Then: the effect is called
        // Then: the effect happens on the dedicated Executer given in the Feedback initializer, not on the one defined
        // on the inputStream
        XCTAssertTrue(effectIsCalled)
        XCTAssertEqual(receivedExecuterName, expectedExecuterName)
    }

    func test_init_produces_a_non_cancellable_stream_when_called_with_continueOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationEffect(outputing: Int) -> AnyPublisher<String, Never> {
            return Future<String, Never> { (observer) in
                sleep(1)
                observer(.success("\(outputing)"))
            }.eraseToAnyPublisher()
        }

        let longOperationQueue = DispatchQueue(label: "FEEDBACK_QUEUE_\(UUID().uuidString)", qos: .background)

        let effect = { (input: Int) -> AnyPublisher<String, Never> in
            if input == 1 {
                return Just<Void>(())
                    .receive(on: longOperationQueue)
                    .flatMap { _ in return makeLongOperationEffect(outputing: input) }
                    .eraseToAnyPublisher()
            }

            return Just<String>("\(input)").eraseToAnyPublisher()
        }

        // Given: this effect being applied a "continueOnNewEvent" strategy
        let sut = DispatchQueueCombineFeedback<Int, String>(effect: effect, applying: .continueOnNewEvent).effect

        // When: feeding this effect with 2 events: 1 and 2
        let recorder = sut([1, 2].publisher.eraseToAnyPublisher()).record()
        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the stream waits for the long operation to end before completing
        XCTAssertEqual(receivedElements, ["2", "1"])
    }

    func test_init_produces_a_cancellable_stream_when_called_with_cancelOnNewEvent_strategy() throws {
        // Given: an effect that performs a long operation when given 1 as an input, and an immediate operation otherwise
        func makeLongOperationEffect(outputing: Int) -> AnyPublisher<String, Never> {
            return Future<String, Never> { (observer) in
                sleep(1)
                observer(.success("\(outputing)"))
            }.eraseToAnyPublisher()
        }

        let longOperationQueue = DispatchQueue(label: "FEEDBACK_QUEUE_\(UUID().uuidString)", qos: .background)

        let effect = { (input: Int) -> AnyPublisher<String, Never> in
            if input == 1 {
                return Just<Void>(())
                    .receive(on: longOperationQueue)
                    .flatMap { _ in return makeLongOperationEffect(outputing: input) }
                    .eraseToAnyPublisher()
            }

            return Just<String>("\(input)").eraseToAnyPublisher()
        }

        // Given: this effect being applied a "cancelOnNewEvent" strategy
        let sut = DispatchQueueCombineFeedback<Int, String>(effect: effect, applying: .cancelOnNewEvent).effect

        // When: feeding this stream with 2 events: 1 and 2
        let recorder = sut([1, 2].publisher.eraseToAnyPublisher()).record()
        let receivedElements = try wait(for: recorder.elements, timeout: 5)

        // Then: the stream does not wait for the long operation to end before completing, the first operation is cancelled in favor
        // of the immediate one
        XCTAssertEqual(receivedElements, ["2"])
    }

    func test_directEffect_is_used() throws {
        var effectIsCalled = false

        // Given: a feedback from a directEffect
        let nilExecuter: DispatchQueue? = nil
        let sut = CombineFeedback(directEffect: { (input: Int) -> String in
            effectIsCalled = true
            return "\(input)"
        }, on: nilExecuter?.eraseToAnyScheduler())

        // When: executing the feedback
        let inputStream = Just<Int>(1701).eraseToAnyPublisher()
        let recorder = sut.effect(inputStream).record()
        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the directEffect is called
        XCTAssertTrue(effectIsCalled)
    }

    func test_effects_are_used() throws {
        var effectAIsCalled = false
        var effectBIsCalled = false

        // Given: a feedback from 2 effects
        let effectA = { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            effectAIsCalled = true
            return inputs.map { "\($0)" }.eraseToAnyPublisher()
        }
        let effectB = { (inputs: AnyPublisher<Int, Never>) -> AnyPublisher<String, Never> in
            effectBIsCalled = true
            return inputs.map { "\($0)" }.eraseToAnyPublisher()
        }

        let sut = DispatchQueueCombineFeedback(effects: [effectA, effectB])

        // When: executing the feedback
        let inputStream = Just<Int>(1701).eraseToAnyPublisher()
        let recorder = sut.effect(inputStream).record()
        _ = try wait(for: recorder.completion, timeout: 5)

        // Then: the effects are called
        XCTAssertTrue(effectAIsCalled)
        XCTAssertTrue(effectBIsCalled)
    }
}
