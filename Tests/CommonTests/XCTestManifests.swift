import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Spin_SwiftTests.allTests),
    ]
}
#endif
