//
//  Obsevable.swift
//  Observely
//
//  Created by Max Baumbach on 31/05/2020.
//

import Foundation
import Combine

@propertyWrapper
public struct Observable<Value> {

    /// Determines whether the closure should be called
    /// with the initial value or only be triggered on changes
    public enum Option {
        case inital
        case new
    }

    private var value: Value

    private var callbacks: [String: (Value) -> Void] = [:]

    public var observers: [Any] {
        Array(callbacks.keys)
    }

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            resolve(value: value)
        }
    }

    public var projectedValue: Observable<Value> {
        self
    }

    // MARK: - Public Accessors -

    // MARK: - Observe a value over time

    /// Observe the wrapped an get value changes. Remember to remove
    /// an observer once observations are no longer needed.
    ///
    /// - Parameters:
    ///   - observer: an observer object
    ///   - option: provide an option whether only to receive new values
    ///   or also intial value
    ///   - onChange: the closure to being called on value change
    public mutating func observe<T: AnyObject>(_ observer: T,
                                 _ option: Option = .inital,
                                 _ onChange: @escaping (Value) -> Void) {
        let key = "\(type(of: observer.self))"
        callbacks[key] = onChange
        switch option {
        case .inital:
            triggerCallbacksIfResolved()
        case .new: break
        }

    }

    // MARK: - Remove an Observer

    /// Pass in the observer you wish to remove from
    /// the observable.
    ///
    /// - Parameter observer: an Observer that conforms to `Hashable`
    public mutating func removeObserver<T: AnyObject>(_ observer: T) {
        let key = "\(type(of: observer.self))"
        callbacks.removeValue(forKey: key)
    }

    public mutating func removeAllObservers() {
        callbacks = [:]
    }

    // MARK: - Signal

    /// Emit a signal to all observers with the current value.
    /// Optionally provide a closure to perform some work first.
    ///
    /// - Parameter after: An optional closure to be used to perform
    /// work before signalling all observers
    public func signal(after: (() -> Void)? = nil) {
        after?()
        triggerCallbacksIfResolved()
    }

    // MARK: - Private 

    private func resolve(value: Value?) {
        triggerCallbacksIfResolved()
    }

    private func triggerCallbacksIfResolved() {
        callbacks.values.forEach { executable in
            executable(value)
        }
    }

}
