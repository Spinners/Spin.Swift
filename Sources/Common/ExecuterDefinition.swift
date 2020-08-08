//
//  ExecuterDefinition.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-04.
//

public protocol ExecuterDefinition {
    associatedtype Executer
    static func defaultSpinExecuter() -> Executer
}
