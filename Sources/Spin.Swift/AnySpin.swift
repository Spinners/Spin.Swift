//
//  AnySpin.swift
//  
//
//  Created by Thibault Wittemberg on 2019-12-29.
//

/// `AnySpin` is a concrete implementation of `Spin`. This is what is to be returned in a concrete SpinDefinition
/// implementation or a `Spinner` building process
public struct AnySpin<StateStream: ReactiveStream>: Spin {
    public let stream: StateStream

    public init<EventStream, ReducerType>(initialState: StateStream.Value,
                                          effects: [(StateStream) -> EventStream],
                                          reducer: ReducerType)
        where
        ReducerType: Reducer,
        ReducerType.StateStream == StateStream,
        EventStream == ReducerType.EventStream {
            self.stream = reducer.apply(on: initialState, after: effects)
    }

    public init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                           feedback: FeedbackType,
                                           reducer: ReducerType)
        where
        FeedbackType: Feedback,
        ReducerType: Reducer,
        FeedbackType.StateStream == StateStream,
        FeedbackType.StateStream.Value == StateStream.Value,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream {
            let effects = [feedback.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }

    public init<FeedbackType, ReducerType>(initialState: StateStream.Value,
                                           reducer: ReducerType,
                                           @FeedbackBuilder feedbackBuilder: () -> FeedbackType)
        where
        FeedbackType: Feedback, ReducerType: Reducer,
        FeedbackType.StateStream == ReducerType.StateStream,
        FeedbackType.EventStream == ReducerType.EventStream,
        FeedbackType.StateStream == StateStream {
            let effects = [feedbackBuilder().effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, ReducerType>(initialState: StateStream.Value,
                                                   reducer: ReducerType,
                                                   @FeedbackBuilder builder: () -> (FeedbackA, FeedbackB))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let effects = [feedbacks.0.effect, feedbacks.1.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, ReducerType>(initialState: StateStream.Value,
                                                              reducer: ReducerType,
                                                              @FeedbackBuilder builder: () -> ( FeedbackA,
                                                                                                FeedbackB,
                                                                                                FeedbackC))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let effects = [feedbacks.0.effect, feedbacks.1.effect, feedbacks.2.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, ReducerType>(initialState: StateStream.Value,
                                                                         reducer: ReducerType,
                                                                         @FeedbackBuilder builder: () -> (  FeedbackA,
                                                                                                            FeedbackB,
                                                                                                            FeedbackC,
                                                                                                            FeedbackD))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        ReducerType: Reducer,
        FeedbackA.StateStream == ReducerType.StateStream,
        FeedbackA.EventStream == ReducerType.EventStream,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let effects = [feedbacks.0.effect, feedbacks.1.effect, feedbacks.2.effect, feedbacks.3.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }

    public init<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE, ReducerType>(initialState: StateStream.Value,
                                                                                    reducer: ReducerType,
                                                                                    @FeedbackBuilder builder: () -> (   FeedbackA,
                                                                                                                        FeedbackB,
                                                                                                                        FeedbackC,
                                                                                                                        FeedbackD,
                                                                                                                        FeedbackE))
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        ReducerType: Reducer,
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
        FeedbackA.StateStream == StateStream {
            let feedbacks = builder()
            let effects = [feedbacks.0.effect, feedbacks.1.effect, feedbacks.2.effect, feedbacks.3.effect, feedbacks.4.effect]
            self.init(initialState: initialState, effects: effects, reducer: reducer)
    }
}

@_functionBuilder
public struct FeedbackBuilder {
    public static func buildBlock<FeedbackType: Feedback>(_ feedback: FeedbackType) -> FeedbackType {
        return feedback
    }

    public static func buildBlock<FeedbackA, FeedbackB>(_ feedbackA: FeedbackA,
                                                        _ feedbackB: FeedbackB) -> (FeedbackA, FeedbackB)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream {
            return (feedbackA, feedbackB)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC>(_ feedbackA: FeedbackA,
                                                                   _ feedbackB: FeedbackB,
                                                                   _ feedbackC: FeedbackC) -> ( FeedbackA,
                                                                                                FeedbackB,
                                                                                                FeedbackC)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream {
            return (feedbackA, feedbackB, feedbackC)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD>(_ feedbackA: FeedbackA,
                                                                              _ feedbackB: FeedbackB,
                                                                              _ feedbackC: FeedbackC,
                                                                              _ feedbackD: FeedbackD) -> (  FeedbackA,
                                                                                                            FeedbackB,
                                                                                                            FeedbackC,
                                                                                                            FeedbackD)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD)
    }

    public static func buildBlock<FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE>(_ feedbackA: FeedbackA,
                                                                                         _ feedbackB: FeedbackB,
                                                                                         _ feedbackC: FeedbackC,
                                                                                         _ feedbackD: FeedbackD,
                                                                                         _ feedbackE: FeedbackE)
        -> (FeedbackA, FeedbackB, FeedbackC, FeedbackD, FeedbackE)
        where
        FeedbackA: Feedback,
        FeedbackB: Feedback,
        FeedbackC: Feedback,
        FeedbackD: Feedback,
        FeedbackE: Feedback,
        FeedbackA.StateStream == FeedbackB.StateStream,
        FeedbackA.EventStream == FeedbackB.EventStream,
        FeedbackB.StateStream == FeedbackC.StateStream,
        FeedbackB.EventStream == FeedbackC.EventStream,
        FeedbackC.StateStream == FeedbackD.StateStream,
        FeedbackC.EventStream == FeedbackD.EventStream,
        FeedbackD.StateStream == FeedbackE.StateStream,
        FeedbackD.EventStream == FeedbackE.EventStream {
            return (feedbackA, feedbackB, feedbackC, feedbackD, feedbackE)
    }
}
