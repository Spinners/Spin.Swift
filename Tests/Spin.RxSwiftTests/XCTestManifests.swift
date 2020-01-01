import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Spin_RxSwiftTests.allTests),
    ]
}
#endif
