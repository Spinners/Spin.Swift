//
//  AnyScheduler.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-30.
//

import Combine
import Dispatch
import Foundation
import SpinCommon

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        return AnyScheduler<SchedulerTimeType, SchedulerOptions>(scheduler: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class AnyScheduler<SchedulerTimeType, SchedulerOptionsType>: Scheduler
where SchedulerTimeType: Strideable, SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    public typealias SchedulerTimeType = SchedulerTimeType
    public typealias SchedulerOptions = SchedulerOptionsType

    private let nowClosure: () -> SchedulerTimeType
    private let minimumToleranceClosure: () -> SchedulerTimeType.Stride
    private let scheduleOptionsClosure: (SchedulerOptions?, @escaping () -> Void) -> Void
    private let scheduleAfterDateClosure: ( SchedulerTimeType,
                                            SchedulerTimeType.Stride,
                                            SchedulerOptions?,
                                            @escaping () -> Void) -> Void
    private let scheduleAfterDateIntervalClosure: ( SchedulerTimeType,
                                                    SchedulerTimeType.Stride,
                                                    SchedulerTimeType.Stride,
                                                    SchedulerOptions?,
                                                    @escaping () -> Void) -> Cancellable

    fileprivate init<SchedulerType: Scheduler>(scheduler: SchedulerType)
        where
        SchedulerType.SchedulerTimeType == SchedulerTimeType,
        SchedulerType.SchedulerOptions == SchedulerOptionsType {
            self.nowClosure = { return scheduler.now }
            self.minimumToleranceClosure = { return scheduler.minimumTolerance }
            self.scheduleOptionsClosure = scheduler.schedule
            self.scheduleAfterDateClosure = scheduler.schedule
            self.scheduleAfterDateIntervalClosure = scheduler.schedule
    }

    public var now: SchedulerTimeType { self.nowClosure() }

    public var minimumTolerance: SchedulerTimeType.Stride { self.minimumToleranceClosure() }

    public func schedule(options: SchedulerOptions?,
                         _ action: @escaping () -> Void) {
        return self.scheduleOptionsClosure(options, action)
    }

    public func schedule(after date: SchedulerTimeType,
                         tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?,
                         _ action: @escaping () -> Void) {
        return self.scheduleAfterDateClosure(date, tolerance, options, action)
    }

    public func schedule(after date: SchedulerTimeType,
                         interval: SchedulerTimeType.Stride,
                         tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?,
                         _ action: @escaping () -> Void) -> Cancellable {
        self.scheduleAfterDateIntervalClosure(date, interval, tolerance, options, action)
    }
}
