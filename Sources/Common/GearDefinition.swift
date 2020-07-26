//
//  GearDefinition.swift
//  
//
//  Created by Thibault Wittemberg on 2020-07-25.
//

public protocol GearDefinition: AnyObject {
    associatedtype Event
    func propagate(event: Event)
}
