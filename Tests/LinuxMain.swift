import XCTest

import SpinCommonTests
import SpinCombineTests

var tests = [XCTestCaseEntry]()
tests += Spin_SwiftTests.allTests()
tests += Spin_CombineTests.allTests()
tests += Spin_ReactiveSwiftTests.allTests()
tests += Spin_RxSwiftTests.allTests()
XCTMain(tests)
