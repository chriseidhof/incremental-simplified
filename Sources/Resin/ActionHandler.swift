import Foundation

public protocol ActionHandler: class {
    /// Handles an action.
    ///
    /// - Important: You should call `dispatch` instead, this method only exists
    ///              since we can't pass default arguments to `file` and `line`.
    func handle(_ action: Action, context: ActionContext)
}

public extension ActionHandler {
    func dispatch(_ action: Action, file: String = #file, line: Int = #line) {
        dispatch(action, context: ActionContext(file: file, line: line))
    }

    /// Dispatches an action.
    func dispatch(_ action: Action, context: ActionContext) {
        DispatchQueue.main.async {
            self.handle(action, context: context)
        }
    }

    func dispatchWithSynchronousExecution(_ action: SystemResponseAction, file: String = #file, line: Int = #line) {
        dispatchWithSynchronousExecution(action, context: ActionContext(file: file, line: line))
    }

    /// Dispatches a `SystemResponseAction` with the intent of being executed
    /// in the same run loop in which it was called.
    ///
    /// Must be called on the main thread.
    func dispatchWithSynchronousExecution(_ action: SystemResponseAction, context: ActionContext) {
        dispatchPrecondition(condition: .onQueue(.main))

        handle(action, context: context)
    }
}
