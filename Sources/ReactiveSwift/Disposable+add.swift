//
//  Disposable+add.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift

public extension Disposable {
    func add(to disposable: CompositeDisposable) {
        disposable.add(self)
    }
}
