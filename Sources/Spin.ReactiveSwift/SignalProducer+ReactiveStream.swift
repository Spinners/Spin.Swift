//
//  SignalProducer+ReactiveStream.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift
import Spin_Swift

extension SignalProducer: ReactiveStream where Error == Never {
    public typealias Value = Value

    public static func emptyStream() -> Self {
        return .empty
    }
}
