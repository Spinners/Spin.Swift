//
//  ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A ReactiveStream is a minimal abstraction to any reactive stream
public protocol ReactiveStream {
    associatedtype Value
    associatedtype LifeCycle

    func spin() -> LifeCycle
    static func emptyStream() -> Self
}
