//
//  PartialTests.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-10.
//

@testable import SpinCommon
import XCTest

final class PartialTests: XCTestCase {
    func testPartial_call_underlying_function_with_1_param() {
        let expectedArg1 = 1
        var receivedArg1: Int?

        // Given: a function that takes 1 arg
        let sut: (Int) -> Int = { arg1 in
            receivedArg1 = arg1
            return arg1
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1)
        _ = partialized()

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
    }

    func testPartial_call_underlying_function_with_2_params_version_1() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        var receivedArg1: Int?
        var receivedArg2: Int?

        // Given: a function that takes 2 args
        let sut: (Int, Int) -> Int = { arg1, arg2 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            return arg1 + arg2
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: .undefined)
        _ = partialized(expectedArg2)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
    }

    func testPartial_call_underlying_function_with_2_params_version_2() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        var receivedArg1: Int?
        var receivedArg2: Int?

        // Given: a function that takes 2 args
        let sut: (Int, Int) -> Int = { arg1, arg2 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            return arg1 + arg2
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: .undefined, arg2: expectedArg2)
        _ = partialized(expectedArg1)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
    }

    func testPartial_call_underlying_function_with_3_params_version_1() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?

        // Given: a function that takes 3 args
        let sut: (Int, Int, Int) -> Int = { arg1, arg2, arg3 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            return arg1 + arg2 + arg3
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: .undefined)
        _ = partialized(expectedArg3)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
    }

    func testPartial_call_underlying_function_with_3_params_version_2() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?

        // Given: a function that takes 3 args
        let sut: (Int, Int, Int) -> Int = { arg1, arg2, arg3 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            return arg1 + arg2 + arg3
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: .undefined, arg3: expectedArg3)
        _ = partialized(expectedArg2)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
    }

    func testPartial_call_underlying_function_with_3_params_version_3() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?

        // Given: a function that takes 3 args
        let sut: (Int, Int, Int) -> Int = { arg1, arg2, arg3 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            return arg1 + arg2 + arg3
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: .undefined, arg2: expectedArg2, arg3: expectedArg3)
        _ = partialized(expectedArg1)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
    }

    func testPartial_call_underlying_function_with_4_params_version_1() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?

        // Given: a function that takes 4 args
        let sut: (Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            return arg1 + arg2 + arg3 + arg4
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: expectedArg3, arg4: .undefined)
        _ = partialized(expectedArg4)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
    }

    func testPartial_call_underlying_function_with_4_params_version_2() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?

        // Given: a function that takes 4 args
        let sut: (Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            return arg1 + arg2 + arg3 + arg4
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: .undefined, arg4: expectedArg4)
        _ = partialized(expectedArg3)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
    }

    func testPartial_call_underlying_function_with_4_params_version_3() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?

        // Given: a function that takes 4 args
        let sut: (Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            return arg1 + arg2 + arg3 + arg4
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: .undefined, arg3: expectedArg3, arg4: expectedArg4)
        _ = partialized(expectedArg2)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
    }

    func testPartial_call_underlying_function_with_4_params_version_4() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?

        // Given: a function that takes 4 args
        let sut: (Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            return arg1 + arg2 + arg3 + arg4
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: .undefined, arg2: expectedArg2, arg3: expectedArg3, arg4: expectedArg4)
        _ = partialized(expectedArg1)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
    }

    func testPartial_call_underlying_function_with_5_params_version_1() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        let expectedArg5 = 5
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?
        var receivedArg5: Int?

        // Given: a function that takes 5 args
        let sut: (Int, Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4, arg5 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            receivedArg5 = arg5
            return arg1 + arg2 + arg3 + arg4 + arg5
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: expectedArg3, arg4: expectedArg4, arg5: .undefined)
        _ = partialized(expectedArg5)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
        XCTAssertEqual(receivedArg5, expectedArg5)
    }

    func testPartial_call_underlying_function_with_5_params_version_2() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        let expectedArg5 = 5
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?
        var receivedArg5: Int?

        // Given: a function that takes 5 args
        let sut: (Int, Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4, arg5 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            receivedArg5 = arg5
            return arg1 + arg2 + arg3 + arg4 + arg5
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: expectedArg3, arg4: .undefined, arg5: expectedArg5)
        _ = partialized(expectedArg4)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
        XCTAssertEqual(receivedArg5, expectedArg5)
    }

    func testPartial_call_underlying_function_with_5_params_version_3() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        let expectedArg5 = 5
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?
        var receivedArg5: Int?

        // Given: a function that takes 5 args
        let sut: (Int, Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4, arg5 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            receivedArg5 = arg5
            return arg1 + arg2 + arg3 + arg4 + arg5
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: expectedArg2, arg3: .undefined, arg4: expectedArg4, arg5: expectedArg5)
        _ = partialized(expectedArg3)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
        XCTAssertEqual(receivedArg5, expectedArg5)
    }

    func testPartial_call_underlying_function_with_5_params_version_4() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        let expectedArg5 = 5
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?
        var receivedArg5: Int?

        // Given: a function that takes 5 args
        let sut: (Int, Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4, arg5 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            receivedArg5 = arg5
            return arg1 + arg2 + arg3 + arg4 + arg5
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: expectedArg1, arg2: .undefined, arg3: expectedArg3, arg4: expectedArg4, arg5: expectedArg5)
        _ = partialized(expectedArg2)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
        XCTAssertEqual(receivedArg5, expectedArg5)
    }

    func testPartial_call_underlying_function_with_5_params_version_5() {
        let expectedArg1 = 1
        let expectedArg2 = 2
        let expectedArg3 = 3
        let expectedArg4 = 4
        let expectedArg5 = 5
        var receivedArg1: Int?
        var receivedArg2: Int?
        var receivedArg3: Int?
        var receivedArg4: Int?
        var receivedArg5: Int?

        // Given: a function that takes 5 args
        let sut: (Int, Int, Int, Int, Int) -> Int = { arg1, arg2, arg3, arg4, arg5 in
            receivedArg1 = arg1
            receivedArg2 = arg2
            receivedArg3 = arg3
            receivedArg4 = arg4
            receivedArg5 = arg5
            return arg1 + arg2 + arg3 + arg4 + arg5
        }

        // When: partializing it and calling the resulting function
        let partialized = partial(sut, arg1: .undefined, arg2: expectedArg2, arg3: expectedArg3, arg4: expectedArg4, arg5: expectedArg5)
        _ = partialized(expectedArg1)

        // Then: the original function is called with the expected args
        XCTAssertEqual(receivedArg1, expectedArg1)
        XCTAssertEqual(receivedArg2, expectedArg2)
        XCTAssertEqual(receivedArg3, expectedArg3)
        XCTAssertEqual(receivedArg4, expectedArg4)
        XCTAssertEqual(receivedArg5, expectedArg5)
    }
}
