//
//  AnyCancellable+DisposeBag.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine

public extension AnyCancellable {
    func disposed(by disposables: inout [AnyCancellable]) {
        self.store(in: &disposables)
    }
}
