//
//  Executer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-05.
//

import Foundation
import RxSwift
import SpinCommon

public class Executer: ExecuterDefinition {
    public typealias Executer = ImmediateSchedulerType
    public static func defaultSpinExecuter() -> Executer {
        SerialDispatchQueueScheduler(internalSerialQueueName: "io.warpfactor.spin.dispatch-queue.\(UUID())")
    }
}
