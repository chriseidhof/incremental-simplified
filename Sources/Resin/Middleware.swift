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

open class Middleware<Action: Resin.Action, State: Equatable>: AnyMiddleware<State> {
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
