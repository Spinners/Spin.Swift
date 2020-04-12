//
//  MockState.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

struct MockState: CanBeEmpty, Equatable {

    let subState: Int

    static var toEmpty: MockState {
        return MockState(subState: 0)
    }
}
