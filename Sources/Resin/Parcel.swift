import Foundation

/// This struct encapsulates everything a module needs to expose to be integrated into a store
public struct Parcel<State: Equatable> {
    public struct Delivery {
        public var middlewares: [AnyMiddleware<State>]

        public var presentationRoutes: [AnyPresentationRoute<State>]

        public var reducers: [AnyReducer<State>]

        public init(middlewares: [AnyMiddleware<State>] = [], presentationRoutes: [AnyPresentationRoute<State>] = [], reducers: [AnyReducer<State>] = []) {
            self.middlewares = middlewares
            self.presentationRoutes = presentationRoutes
            self.reducers = reducers
        }
    }

    public var build: (Store<State>) -> Parcel<State>.Delivery

    public init(build: @escaping (Store<State>) -> Parcel<State>.Delivery) {
        self.build = build
    }
}

extension Parcel {
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> Parcel<Superstate> {
        return Parcel<Superstate> { store in
            let localStore = store.focused(by: keyPath)
            return self.build(localStore).unfocused(by: keyPath)
        }
    }

    public func combining(with other: Parcel<State>) -> Parcel<State> {
        Parcel<State> { store in
            self.build(store).combining(with: other.build(store))
        }
    }
}

extension Parcel.Delivery {
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> Parcel<Superstate>.Delivery {
        var result = Parcel<Superstate>.Delivery()
        result.middlewares = middlewares.map { $0.unfocused(by: keyPath) }
        result.presentationRoutes = presentationRoutes.map { $0.unfocused(by: keyPath) }
        result.reducers = reducers.map { $0.unfocused(by: keyPath) }
        return result
    }

    public func combining(with other: Parcel<State>.Delivery) -> Parcel<State>.Delivery  {
        Parcel<State>.Delivery(
            middlewares: middlewares + other.middlewares,
            presentationRoutes: presentationRoutes + other.presentationRoutes,
            reducers: reducers + other.reducers
        )
    }
}

extension Parcel where State == ArbitraryState {
    /// Unfocuses a `Parcel<ArbitraryState>` to a `Parcel<S>` for any `S`.
    public func unfocused<Superstate: Equatable>(to superstate: Superstate.Type = Superstate.self) -> Parcel<Superstate> {
        return unfocused(by: ArbitraryState.arbitraryKeyPath())
    }
}
