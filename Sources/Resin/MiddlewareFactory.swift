import Incremental

public class MiddlewareFactory<State: Equatable, Environment> {
    private let closure: (I<State>, Environment) -> AnyMiddleware<State>

    public init(closure: @escaping (I<State>, Environment) -> AnyMiddleware<State>) {
        self.closure = closure
    }

    public func make(state: I<State>, environment: Environment) -> AnyMiddleware<State> {
        return closure(state, environment)
    }

    public func unfocused<Superstate: Equatable>(by keyPath: KeyPath<Superstate, State>) -> MiddlewareFactory<Superstate, Environment> {
        return MiddlewareFactory<Superstate, Environment> { state, environment in
            let substate = state[keyPath]

            return self.make(state: substate, environment: environment).unfocused(by: keyPath)
        }
    }

    public func lift<E>(proof: @escaping (E) -> Environment) -> MiddlewareFactory<State, E> {
        return MiddlewareFactory<State, E> { state, environment in
            return self.make(state: state, environment: proof(environment))
        }
    }
}
