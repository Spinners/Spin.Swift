//
//  AnyCancellable+DisposeBagTests.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine
import Spin_Combine
import XCTest

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class AnyCancellable_DisposeBagTests: XCTestCase {
    func test_disposedBy_adds_the_expected_number_of_cancellables() {
        // Given: an empty disposeBag and several cancellables
        var disposeBag = [AnyCancellable]()

        let cancellableA = AnyCancellable { () in return () }
        let cancellableB = AnyCancellable { () in return () }

        // When: using a disposeBag to store the cancellables
        cancellableA.disposed(by: &disposeBag)
        cancellableB.disposed(by: &disposeBag)

        // Then: the disposeBag is filled in with the expected cancellables
        XCTAssertEqual(disposeBag.count, 2)
        XCTAssertEqual(disposeBag[0].hashValue, cancellableA.hashValue)
        XCTAssertEqual(disposeBag[1].hashValue, cancellableB.hashValue)
    }
}
