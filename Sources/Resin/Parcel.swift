import Foundation

public struct Parcel<State: Equatable, Environment: Any> {
    @available(*, deprecated, message: "Use middleware instead")
    public var legacyMiddleware: [AnyMiddleware<State>] = []

    public var middleware: [MiddlewareFactory<State, Environment>] = []

    public var presentationRoutes: [AnyPresentationRoute<State>] = []

    public var reducers: [AnyReducer<State>] = []

    public init() {}
}

extension Parcel {
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> Parcel<Superstate, Environment> {
        var result = Parcel<Superstate, Environment>()
        result.legacyMiddleware = legacyMiddleware.map { $0.unfocused(by: keyPath) }
        result.middleware = middleware.map { $0.unfocused(by: keyPath) }
        result.presentationRoutes = presentationRoutes.map { $0.unfocused(by: keyPath) }
        result.reducers = reducers.map { $0.unfocused(by: keyPath) }

        return result
    }

    public func lift<E>(proof: @escaping (E) -> Environment) -> Parcel<State, E> {
        var result = Parcel<State, E>()
        result.legacyMiddleware = legacyMiddleware
        result.middleware = middleware.map { $0.lift(proof: proof) }
        result.presentationRoutes = presentationRoutes
        result.reducers = reducers

        return result
    }
}

extension Parcel where State == ArbitraryState {
    /// Unfocuses a `Parcel<ArbitraryState>` to a `Parcel<S>` for any `S`.
    public func arbitrarilyUnfocused<Superstate: Equatable>(to superstate: Superstate.Type) -> Parcel<Superstate, Environment> {
        return unfocused(by: ArbitraryState.arbitraryKeyPath())
    }
}
