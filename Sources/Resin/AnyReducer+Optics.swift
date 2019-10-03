import Foundation

extension AnyReducer {
    /// These methods create a new Reducer for a state that contains the
    /// state of the receiver.
    ///
    /// This allows us to write a `Reducer` focused on the most specific state
    /// they need to know about and defer the integration into the `Superstate`.
    ///
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
