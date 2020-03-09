//
//  CombineSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Spin_Swift

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class CombineSpin<State, Event>: AnySpin<AnyPublisher<State, Never>, AnyPublisher<Event, Never>> {
    public override func toReactiveStream() -> StateStream {
        AnyPublisher<State, Never>.stream(from: self)
    }
}
