//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public typealias Spin<State, Event> = AnySpin<SignalProducer<State, Never>, SignalProducer<Event, Never>>

public typealias ReactiveSpin = Spin_ReactiveSwift.Spin
