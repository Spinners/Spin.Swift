//
//  CombineSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Spin_Swift

public typealias CombineSpin<State, Event> = AnySpin<AnyPublisher<State, Never>, AnyPublisher<Event, Never>>
