import XCTest

import Spin_SwiftTests
import Spin_CombineTests

var tests = [XCTestCaseEntry]()
tests += Spin_SwiftTests.allTests()
tests += Spin_CombineTests.allTests()
XCTMain(tests)
