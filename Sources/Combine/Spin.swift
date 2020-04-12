//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias Spin<State, Event> = AnySpin<AnyPublisher<State, Never>, AnyPublisher<Event, Never>>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineSpin = SpinCombine.Spin
