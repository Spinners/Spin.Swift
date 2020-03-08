//
//  Weakify.swift
//  
//
//  Created by Thibault Wittemberg on 2020-01-09.
//

public func weakify<Container: AnyObject, T>(container: Container, function: @escaping (Container) -> (T) -> Void) -> (T) -> Void {
    return { [weak container] input in
        guard let container = container else { return }
        return function(container)(input)
    }
}
