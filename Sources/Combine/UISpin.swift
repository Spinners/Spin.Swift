//
//  CombineUISpin.swift
//  
//
//  Created by Thibault Wittemberg on 2020-02-08.
//

import Combine
import SpinCommon
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public typealias CombineUISpin = SpinCombine.UISpin

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public final class UISpin<State, Event>: Spin<State, Event>, StateRenderer, EventEmitter {
    private var disposeBag = [AnyCancellable]()
    private let events = PassthroughSubject<Event, Never>()
    private var externalRenderFunction: ((State) -> Void)?
    public var state: State {
        didSet {
            self.externalRenderFunction?(state)
        }
    }
    
    public init(spin: Spin<State, Event>) {
        self.state = spin.initialState
        super.init(initialState: spin.initialState, effects: spin.effects, scheduledReducer: spin.scheduledReducer)
        let uiFeedback = Feedback<State, Event>(uiEffects: { [weak self] state in
            self?.state = state
            }, { [weak self] in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                return self.events.eraseToAnyPublisher()
            }, on: DispatchQueue.main.eraseToAnyScheduler())
        self.effects = [uiFeedback.effect] + spin.effects
    }

    public func render<Container: AnyObject>(on container: Container, using function: @escaping (Container) -> (State) -> Void) {
        self.externalRenderFunction = weakify(container: container, function: function)
    }

    public func emit(_ event: Event) {
        self.events.send(event)
    }

    public func start() {
        AnyPublisher.start(spin: self).store(in: &self.disposeBag)
    }

    deinit {
        self.disposeBag.forEach { $0.cancel() }
    }
}
