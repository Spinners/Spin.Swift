# Spin.swift

**Spin** aims to provide a versatile Feedback Loop implementation working with the three main reactive frameworks available in the Swift community:

* Combine ([https://developer.apple.com/documentation/combine]())
* RxSwift ([https://github.com/ReactiveX/RxSwift]())
* ReactiveSwift ([https://github.com/ReactiveCocoa/ReactiveSwift]())

**Spin** offers a unified syntax whatever the underlying reactive framework you choose to use.

**Spin** allows to build a Feedback Loop very easily either using a builder pattern, or using a declarative "SwiftUI like" syntax.

```swift
Spinner
    .from(initialState: State.loading(planet: planet))
    .add(feedback: ReactiveFeedback(feedback: loadFeedback, on: QueueScheduler()))
    .add(feedback: ReactiveFeedback(uiFeedbacks: renderStateFeedback, emitActionFeedback, on: UIScheduler()))
    .reduce(with: ReactiveReducer(reducer: reducer))
```

or

```swift
var spin: ReactiveSpin<State> {
    ReactiveSpin(initialState: State.loading(planet: planet),
                 reducer: ReactiveReducer(reducer: reducer)) {
        ReactiveFeedback(feedback: loadFeedback).execute(on: QueueScheduler())
        ReactiveFeedback(uiFeedbacks: renderStateFeedback, emitActionFeedback).execute(on: UIScheduler())
    }
}
```
    
    