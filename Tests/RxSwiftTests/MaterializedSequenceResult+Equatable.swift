//
//  MaterializedSequenceResult+Equatable.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxBlocking

extension MaterializedSequenceResult: Equatable where T: Equatable {
    public static func == (lhs: MaterializedSequenceResult<T>, rhs: MaterializedSequenceResult<T>) -> Bool {
        switch (lhs, rhs) {
        case (.completed(let lhsElements), .completed(elements: let rhsElements)):
            return lhsElements == rhsElements
        case (.failed(let lhsElements, let lhsError), .failed(let rhsElements, let rhsError)):
            return lhsElements == rhsElements && lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
