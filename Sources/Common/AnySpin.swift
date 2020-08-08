//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//
import Foundation

open class AnySpin<StateStream: ReactiveStream, EventStream: ReactiveStream, Executer: ExecuterDefinition>: SpinDefinition {
    public let initialState: StateStream.Value
    public var effects: [(StateStream) -> EventStream]
    public let reducer: (StateStream.Value, EventStream.Value) -> StateStream.Value
    public let executer: Executer.Executer

    public init(initialState: StateStream.Value,
                effects: [(StateStream) -> EventStream],
                reducer: @escaping (StateStream.Value, EventStream.Value) -> StateStream.Value,
                executer: Executer.Executer = Executer.defaultSpinExecuter()) {
        self.initialState = initialState
        self.effects = effects
        self.reducer = reducer
        self.executer = executer
    }

    public convenience init<Feedback>(
        initialState: StateStream.Value,
        feedback: Feedback,
        reducer: Reducer<Feedback.StateStream.Value, Feedback.EventStream.Value>,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter()
    ) where
        Feedback: FeedbackDefinition,
        Feedback.StateStream == StateStream,
        Feedback.EventStream == EventStream {
            let effects = [feedback.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }

    public convenience init<Feedback>(
        initialState: StateStream.Value,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter(),
        @FeedbackBuilder builder: () -> (Feedback, Reducer<Feedback.StateStream.Value, Feedback.EventStream.Value>)
    ) where
        Feedback: FeedbackDefinition,
        Feedback.StateStream == StateStream,
        Feedback.EventStream == EventStream{
            let (feedback, reducer) = builder()
            let effects = [feedback.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }

    public convenience init<FeedbackA, FeedbackB>(
        initialState: StateStream.Value,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter(),
        @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
    ) where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream {
            let (feedback1, feedback2, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC>(
        initialState: StateStream.Value,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter(),
        @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, FeedbackC, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
    ) where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream,
        FeedbackA.EventStream == EventStream {
            let (feedback1, feedback2, feedback3, reducer) = builder()
            let effects = [feedback1.effect, feedback2.effect, feedback3.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(
        initialState: StateStream.Value,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter(),
        @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
    ) where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
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
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }

    public convenience init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(
        initialState: StateStream.Value,
        executeOn executer: Executer.Executer = Executer.defaultSpinExecuter(),
        @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
    ) where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        FeedbackE: FeedbackDefinition,
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
            self.init(initialState: initialState, effects: effects, reducer: reducer.reducer, executer: executer)
    }
}

@_functionBuilder
public struct FeedbackBuilder {
    public static func buildBlock<Feedback>(
        _ feedback: Feedback,
        _ reducer: Reducer<Feedback.StateStream.Value, Feedback.EventStream.Value>
    ) -> (Feedback, Reducer<Feedback.StateStream.Value, Feedback.EventStream.Value>)
        where
        Feedback: FeedbackDefinition {
            return (feedback, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB>(
        _ feedbackA: FeedbackA,
        _ feedbackB: FeedbackB,
        _ reducer: Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>
    ) -> (FeedbackA, FeedbackB, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream {
            return (feedbackA, feedbackB, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC>(
        _ feedbackA: FeedbackA,
        _ feedbackB: FeedbackB,
        _ feedbackC: FeedbackC,
        _ reducer: Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>
    ) -> (FeedbackA, FeedbackB, FeedbackC, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream {
            return (feedbackA, feedbackB, feedbackC, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(
        _ feedbackA: FeedbackA,
        _ feedbackB: FeedbackB,
        _ feedbackC: FeedbackC,
        _ feedbackD: FeedbackD,
        _ reducer: Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>
    ) -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD, reducer)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(
        _ feedbackA: FeedbackA,
        _ feedbackB: FeedbackB,
        _ feedbackC: FeedbackC,
        _ feedbackD: FeedbackD,
        _ feedbackE: FeedbackE,
        _ reducer: Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>
    ) -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, Reducer<FeedbackA.StateStream.Value, FeedbackA.EventStream.Value>)
        where
        FeedbackA: FeedbackDefinition,
        FeedbackB: FeedbackDefinition,
        FeedbackC: FeedbackDefinition,
        FeedbackD: FeedbackDefinition,
        FeedbackE: FeedbackDefinition,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD, feedbackE, reducer)
    }
}
