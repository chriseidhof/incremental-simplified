import Foundation

extension AnyReducer {
    /// These methods create a new Reducer for a state that contains the
    /// state of the receiver.
    ///
    /// This allows us to write `Reducer` focused on most specific state
    /// they need to know about and defer the integration into the `Superstate`.

    /// - Parameters:
    ///   - by: A `WritableKeyPath` that maps from the superstate to the state
    ///         of the receiver.
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> AnyReducer<Superstate> {
        return AnyReducer<Superstate>(actionIdentifier: actionIdentifier) { [perform] action, superstate in
            var property = superstate[keyPath: keyPath]

            perform(action, &property)

            superstate[keyPath: keyPath] = property
        }
    }
}

extension AnyReducer {
    /// this unfocus a non-optional reducer into an optional one, only applying the action if the state is non-nil
    public func optional() -> AnyReducer<State?> {
        return AnyReducer<State?>(actionIdentifier: actionIdentifier) { [perform] action, optionalState in
            guard var state = optionalState else {
                print("\(type(of: self)) optional reducer : state \(type(of: optionalState)) is nil => not running")
                return
            }

            perform(action, &state)
            optionalState = state
        }
    }
}
