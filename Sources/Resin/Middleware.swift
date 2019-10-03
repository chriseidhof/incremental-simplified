import Foundation
import Incremental

open class AnyMiddleware<State: Equatable> {
    open weak var actionHandler: ActionHandler?

    open func transform(action: Action, context: ActionContext, state: State) -> Action? {
        return action
    }

    public init() {}

    public func dispatch(_ action: Action, file: String = #file, line: Int = #line) {
        let context = ActionContext(file: file, line: line)

        dispatch(action, context: context)
    }

    public func dispatch(_ action: Action, context: ActionContext) {
        actionHandler!.dispatch(action, context: context)
    }
}

open class Middleware<Action: Resin.Action, Environment, State: Equatable>: AnyMiddleware<State> {
    public let environment: Environment

    open class var factory: MiddlewareFactory<State, Environment> {
        return MiddlewareFactory { state, environment in
            return self.init(state: state, environment: environment)
        }
    }

    required public init(state: I<State>, environment: Environment) {
        self.environment = environment
    }

    open func transform(action: Action, context: ActionContext, state: State) -> Resin.Action? {
        return action
    }

    override open func transform(action: Resin.Action, context: ActionContext, state: State) -> Resin.Action? {
        if let action = action as? Action {
            return transform(action: action, context: context, state: state)
        } else {
            return action
        }
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

extension AnyMiddleware {
    public func unfocused<Superstate: Equatable>(by keyPath: KeyPath<Superstate, State>) -> AnyMiddleware<Superstate> {
        return ProxyMiddleware(keyPath: keyPath, proxied: self)
    }
}
