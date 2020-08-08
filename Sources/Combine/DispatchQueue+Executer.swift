//
//  DispatchQueue+Executer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-04.
//

import Dispatch
import Foundation
import SpinCommon

extension DispatchQueue: ExecuterDefinition {
    public typealias Executer = DispatchQueue
    public static func defaultSpinExecuter() -> Executer {
        DispatchQueue(label: "io.warpfactor.spin.dispatch-queue.\(UUID())")
    }
}
