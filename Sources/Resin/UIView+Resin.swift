import UIKit
import ObjectiveC

extension UIView {
    /// The `ActionHandler` the receiver should send its actions to.
    ///
    /// Set the corresponding `actionHandler` property on the view controller
    /// that owns the view tree containing the receiver to make it accessible
    /// here.
    public var actionHandler: ActionHandler? {
        get {
            let controller = responderChain.first { $0 is UIViewController } as? UIViewController
            return controller?.actionHandler
        }
    }

    private var responderChain: AnyIterator<UIResponder> {
        var responder = next

        return AnyIterator {
            defer {
                responder = responder?.next
            }

            return responder
        }
    }

    public func dispatch(_ action: Action, file: String = #file, line: Int = #line) {
        let controller = responderChain.first { $0 is UIViewController } as? UIViewController

        let context = ActionContext(file: file, line: line, view: self, viewController: controller)

        actionHandler?.dispatch(action, context: context)
    }

    public func dispatchWithSynchronousExecution(_ action: SystemResponseAction, file: String = #file, line: Int = #line) {
        let context = ActionContext(file: file, line: line, view: self)

        actionHandler?.dispatchWithSynchronousExecution(action, context: context)
    }
}
