**version 0.20.0**:

* add a short syntax to build a feedback attached to a Gear

**version 0.19.0**:

* add helper constructors for Feedback to be able to pass dependencies

**version 0.18.0**:

* breaking: Executers are no longer associated to a Reducer but to the whole Spin instead (and can still be overriden in each Feedback) 

**version 0.17.0**:

* introduce Gear: a mediator pattern between Spins that allows them to communicate together
* include the Reducer in the Spin definition with the DSL like syntax

**version 0.16.1**:

* fix memory leak in the stream creation in the operator from(spin:)
* CocoaPods support

**version 0.16**:

* Add Carthage support.
* **Breaking change**: Please note the frameworks renaming: Spin\_Swift -> SpinCommon, Spin\_RxSwift -> SpinRxSwift, Spin\_ReactiveSwift -> SpinReactiveSwift and Spin\_Combine -> SpinCombine.
