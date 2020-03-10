//
//  RxSpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

public typealias RxSpin<State, Event> = AnySpin<Observable<State>, Observable<Event>>
