//
//  AnyPublisher+subscribe.swift
//  
//
//  Created by Thibault Wittemberg on 2020-03-08.
//

import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    func subscribe() -> AnyCancellable {
        return self.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
