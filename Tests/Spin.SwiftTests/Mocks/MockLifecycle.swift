//
//  MockLifecycle.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

class MockLifecycle {
    func afterSpin(function: () -> Void) {
        function()
    }
}
