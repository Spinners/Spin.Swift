//
//  Executer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-05.
//

import Foundation
import ReactiveSwift
import SpinCommon

public class Executer: ExecuterDefinition {
    public typealias Executer = Scheduler
    public static func defaultSpinExecuter() -> Executer {
        let queueName = "io.warpfactor.spin.dispatch-queue.\(UUID())"
        let dispatchQueue = DispatchQueue(label: queueName)
        return QueueScheduler(qos: .default, name: queueName, targeting: dispatchQueue)
    }
}
