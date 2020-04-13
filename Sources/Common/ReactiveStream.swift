//
//  ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A ReactiveStream is a minimal abstraction to any reactive stream
public protocol ReactiveStream {
    associatedtype Value
    associatedtype Subscription

    static func emptyStream() -> Self
    func consume() -> Subscription
}
