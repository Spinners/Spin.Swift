//
//  OperationQueue+Executer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-04.
//

import Foundation
import SpinCommon

extension OperationQueue: ExecuterDefinition {
    public typealias Executer = OperationQueue
    public static func defaultSpinExecuter() -> Executer {
        let queue = OperationQueue()
        queue.name = "io.warpfactor.spin.operationqueue.\(UUID())"
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
