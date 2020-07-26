//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

open class AnySpin<StateStream: ReactiveStream, EventStream: ReactiveStream>: SpinDefinition {
    public var initialState: StateStream.Value
    public var effects: [(StateStream) -> EventStream]
    public var scheduledReducer: (EventStream) -> StateStream

    public init(initialState: StateStream.Value,
                effects: [(StateStream) -> EventStream],
                scheduledReducer: @escaping (EventStream) -> StateStream) {
        self.initialState = initialState
        self.effects = effects
        self.scheduledReducer = scheduledReducer
    }

    public convenience init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                                       feedback: FeedbackType,
                                                       reducer: ReducerType)
        where
        FeedbackType: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream,
        FeedbackType.StateStream.Value == StateStream.Value,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream {
            let effects = [feedback.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }

    public convenience init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                                       @FeedbackBuilder builder: () -> (FeedbackType, ReducerType))
        where
        FeedbackType: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream,
        FeedbackType.StateStream == StateStream,
        FeedbackType.EventStream == EventStream {
            let (feedback, reducer) = builder()
            let effects = [feedback.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }

    public convenience init<FeedbackA, FeedbackB, ReducerType>(initialState: StateStream.Value,
                                                               @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, ReducerType))
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let (feedback1, feedback2, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC, ReducerType>(initialState: StateStream.Value,
                                                                          @FeedbackBuilder builder: () -> ( FeedbackA,
                                                                                                            FeedbackB,
                                                                                                            FeedbackC,
                                                                                                            ReducerType))
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let (feedback1, feedback2, feedback3, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect, feedback3.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType>(initialState: StateStream.Value,
                                                                                     @FeedbackBuilder builder: () -> (  FeedbackA,
                                                                                                                        FeedbackB,
                                                                                                                        FeedbackC,
                                                                                                                        FeedbackD,
                                                                                                                        ReducerType))
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let (feedback1, feedback2, feedback3, feedback4, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect, feedback3.effect, feedback4.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType>(initialState: StateStream.Value,
                                                                                                @FeedbackBuilder builder: () -> (   FeedbackA,
                                                                                                                                    FeedbackB,
                                                                                                                                    FeedbackC,
                                                                                                                                    FeedbackD,
                                                                                                                                    FeedbackE,
                                                                                                                                    ReducerType))
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        FeedbackE: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let (feedback1, feedback2, feedback3, feedback4, feedback5, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect, feedback3.effect, feedback4.effect, feedback5.effect]
            self.init(initialState: initialState, effects: effects, scheduledReducer: reducer.scheduledReducer(with: initialState))
    }
}

@_functionBuilder
public struct FeedbackBuilder {
    public static func buildBlock<FeedbackType, ReducerType>(_ feedback: FeedbackType, _ reducer: ReducerType)
        -> (FeedbackType, ReducerType)
        where
        FeedbackType: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream {
            return (feedback, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, ReducerType>(_ feedbackA: FeedbackA,
                                                                     _ feedbackB: FeedbackB,
                                                                     _ reducer: ReducerType)
        -> (FeedbackA, FeedbackB, ReducerType)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream {
            return (feedbackA, feedbackB, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, ReducerType>(_ feedbackA: FeedbackA,
                                                                                _ feedbackB: FeedbackB,
                                                                                _ feedbackC: FeedbackC,
                                                                                _ reducer: ReducerType)
        -> (FeedbackA, FeedbackB, FeedbackC, ReducerType)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream  {
            return (feedbackA, feedbackB, feedbackC, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType>(_ feedbackA: FeedbackA,
                                                                                           _ feedbackB: FeedbackB,
                                                                                           _ feedbackC: FeedbackC,
                                                                                           _ feedbackD: FeedbackD,
                                                                                           _ reducer: ReducerType)
        -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType>(_ feedbackA: FeedbackA,
                                                                                                      _ feedbackB: FeedbackB,
                                                                                                      _ feedbackC: FeedbackC,
                                                                                                      _ feedbackD: FeedbackD,
                                                                                                      _ feedbackE: FeedbackE,
                                                                                                      _ reducer: ReducerType)
        -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        FeedbackE: FeedbackDefinition,
        ReducerType: ReducerDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream  {
            return (feedbackA, feedbackB, feedbackC, feedbackD, feedbackE, reducer)
    }
}
