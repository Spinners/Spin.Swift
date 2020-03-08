//
//  ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// A ReactiveStream is a minimal abstraction to any reactive stream
public protocol ReactiveStream {
    associatedtype Value

    static func emptyStream() -> Self
}
