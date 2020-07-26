//
//  MockGear.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-26.
//

import SpinCommon

enum MockGearEvent: Equatable {
    case event
}

final class MockGear: GearDefinition {

    var receivedEvent: MockGearEvent?

    func propagate(event: MockGearEvent) {
        self.receivedEvent = event
    }
}
