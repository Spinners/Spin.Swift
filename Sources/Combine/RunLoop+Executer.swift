//
//  RunLoop+Executer.swift
//  
//
//  Created by Thibault Wittemberg on 2020-08-04.
//

import Foundation
import SpinCommon

extension RunLoop: ExecuterDefinition {
    public typealias Executer = RunLoop
    public static func defaultSpinExecuter() -> Executer {
        RunLoop.main
    }
}
