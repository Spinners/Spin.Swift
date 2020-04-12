//
//  SignalProducer+Deferred.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import ReactiveSwift

// from https://github.com/babylonhealth/ReactiveFeedback/blob/develop/ReactiveFeedback/SignalProducer%2BSystem.swift
extension SignalProducer {
    static func deferred(_ producer: @escaping () -> SignalProducer<Value, Error>) -> SignalProducer<Value, Error> {
        return SignalProducer { observer, lifetime in
            lifetime += producer().start(observer)
        }
    }
}
