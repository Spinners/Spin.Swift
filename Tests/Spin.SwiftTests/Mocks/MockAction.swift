//
//  MockAction.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

struct MockAction: CanBeEmpty, Equatable {

    let value: Int

    static var toEmpty: MockAction {
        return MockAction(value: 0)
    }
}
