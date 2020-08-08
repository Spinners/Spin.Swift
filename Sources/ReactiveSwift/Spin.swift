//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import SpinCommon

public typealias Spin<State, Event> = AnySpin<SignalProducer<State, Never>, SignalProducer<Event, Never>, Executer>

public typealias ReactiveSpin = SpinReactiveSwift.Spin
