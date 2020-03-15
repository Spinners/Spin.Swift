//
//  EventEmitter.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-15.
//

public protocol EventEmitter {
    associatedtype Event

    func emit(_ event: Event)
}
