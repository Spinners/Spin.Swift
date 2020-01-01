//
//  File.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import Dispatch

extension DispatchQueue {
    class var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
