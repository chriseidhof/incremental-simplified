import Foundation

/// This method create a new Middleware for a state that contains the
/// state of the receiver.
///
/// This allows us to write `Middleware` focused on most specific state
/// they need to know about and defer the integration into the `Superstate`.

/// - Parameters:
///   - by: A `WritableKeyPath` that maps from the superstate to the state
///         of the receiver.
extension AnyMiddleware {
    public func unfocused<Superstate: Equatable>(by keyPath: KeyPath<Superstate, State>) -> AnyMiddleware<Superstate> {
        return ProxyMiddleware(keyPath: keyPath, proxied: self)
    }
}

extension AnyMiddleware where State == ArbitraryState {
    public func unfocused<Superstate: Equatable>(to superState: Superstate.Type = Superstate.self) -> AnyMiddleware<Superstate> {
        return unfocused(by: ArbitraryState.arbitraryKeyPath())
    }
}

private final class ProxyMiddleware<Substate: Equatable, Superstate: Equatable>: AnyMiddleware<Superstate> {
    override var actionHandler: ActionHandler? {
        get {
            return proxied.actionHandler
        }
        set {
            proxied.actionHandler = newValue
        }
    }

    let keyPath: KeyPath<Superstate, Substate>

    let proxied: AnyMiddleware<Substate>

    init(keyPath: KeyPath<Superstate, Substate>, proxied: AnyMiddleware<Substate>) {
        self.keyPath = keyPath
        self.proxied = proxied
    }

    override public func transform(action: Resin.Action, context: ActionContext, state: Superstate) -> Resin.Action? {
        return proxied.transform(action: action, context: context, state: state[keyPath: keyPath])
    }
}

/// this unfocus a non-optional middleware into an optional one, only performing the transform if the state is non-nil
extension Middleware {
    public func optional(behavior: OptionalMiddlwareBehavior) -> Middleware<Action, State?> {
        return OptionalProxyMiddleware(behavior: behavior, proxied: self)
    }
}

/// This defines a middleware behavior when the optional `State` is nil.
///  - `consume`: the middleware "consumes" the action and returns nil, other middlewares or reducers will NOT be able to act on it
///  - `passthrough`: the middleware returns the action untouched, so that it can be handled by other middlewares and reducers
public enum OptionalMiddlwareBehavior {
    case consume
    case passthrough
}

private final class OptionalProxyMiddleware<Action: Resin.Action, State: Equatable>: Middleware<Action, State?> {
    override var actionHandler: ActionHandler? {
        get {
            return proxied.actionHandler
        }
        set {
            proxied.actionHandler = newValue
        }
    }

    let proxied: AnyMiddleware<State>
    let behavior: OptionalMiddlwareBehavior

    init(behavior: OptionalMiddlwareBehavior, proxied: AnyMiddleware<State>) {
        self.behavior = behavior
        self.proxied = proxied
    }

    override public func transform(action: Action, context: ActionContext, state: State?) -> Resin.Action? {
        guard let actualState = state else {
            switch behavior {
            case .consume:
                print("\(type(of: proxied)) optional middleware : state(\(type(of: state))) is nil => consuming \(type(of: action))")
                return nil
            case .passthrough:
                print("\(type(of: proxied)) optional middleware : state(\(type(of: state))) is nil => letting \(type(of: action)) pass through")
                return action
            }
        }

        return proxied.transform(action: action, context: context, state: actualState)
    }
}
