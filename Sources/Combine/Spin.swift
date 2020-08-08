//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Combine
import Dispatch
import Foundation
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias ScheduledSpin<State, Event, Executer> = AnySpin<AnyPublisher<State, Never>, AnyPublisher<Event, Never>, Executer>
    where Executer: ExecuterDefinition, Executer.Executer: Scheduler

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias Spin<State, Event> = ScheduledSpin<State, Event, DispatchQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias RunLoopSpin<State, Event> = ScheduledSpin<State, Event, RunLoop>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias OperationQueueSpin<State, Event> = ScheduledSpin<State, Event, OperationQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineSpin = SpinCombine.Spin
