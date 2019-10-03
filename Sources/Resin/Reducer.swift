import Foundation

/// A `Reducer` modifies a `State` based on an `Action` it receives using a pure
/// function.
public protocol Reducer {
    associatedtype Action: Resin.Action

    associatedtype State: Equatable

    func reduce(action: Action, state: inout State)
}

public extension Reducer {
    var typeErased: AnyReducer<State> {
        return AnyReducer(reducer: self.reduce)
    }
}

/// An `AnyReducer` erases the `Action` type of a `Reducer`.
public struct AnyReducer<State: Equatable> {
    internal let actionIdentifier: TypeIdentifier

    internal let perform: (Any, inout State) -> Void

    internal init(actionIdentifier: TypeIdentifier, perform: @escaping (Any, inout State) -> Void) {
        self.actionIdentifier = actionIdentifier
        self.perform = perform
    }

    /// Initializes a new Reducer.
    ///
    /// - Parameters:
    ///   - reducer: A pure function that modifies a state based on an `Action`.
    public init<A: Action>(reducer: @escaping (A, inout State) -> Void) {
        actionIdentifier = TypeIdentifier(type: A.self)

        perform = { action, state in
            if let actual = action as? A {
                reducer(actual, &state)
            }
        }
    }

    public func reduce(action: Any, state: inout State) {
        perform(action, &state)
    }
}
