//
//  Spinner.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-04.
//

import Dispatch
import Foundation
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias Spinner<State> = AnySpinner<State, DispatchQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias RunLoopSpinner<State> = AnySpinner<State, RunLoop>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias OperationQueueSpinner<State> = AnySpinner<State, OperationQueue>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineSpinner = SpinCombine.Spinner
