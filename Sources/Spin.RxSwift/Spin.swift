//
//  Spin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-31.
//

import RxSwift
import Spin_Swift

public typealias Spin<State, Event> = AnySpin<Observable<State>, Observable<Event>>

public typealias RxSpin = Spin_RxSwift.Spin
