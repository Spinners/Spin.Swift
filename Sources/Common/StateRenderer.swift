//
//  StateRenderer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-15.
//

public protocol StateRenderer {
    associatedtype State

    var state: State { get }
}

#if canImport(Combine)
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension StateRenderer where Self: EventEmitter {
    func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: @escaping (SubState) -> Event) -> Binding<SubState> {
        return Binding(get: { self.state[keyPath: keyPath] }, set: { self.emit(event($0)) })
    }

    func binding<SubState>(for keyPath: KeyPath<State, SubState>, event: Event) -> Binding<SubState> {
        return self.binding(for: keyPath) { _ -> Event in
            event
        }
    }
}
#endif
