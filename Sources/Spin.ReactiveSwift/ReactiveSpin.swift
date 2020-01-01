//
//  ReactiveSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

public typealias ReactiveSpin<Value> = AnySpin<SignalProducer<Value, Never>>
