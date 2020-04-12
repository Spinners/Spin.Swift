//
//  AnyCancellable+DisposeBag.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension AnyCancellable {
    func disposed(by disposables: inout [AnyCancellable]) {
        self.store(in: &disposables)
    }
}
