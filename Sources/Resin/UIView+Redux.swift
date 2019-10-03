import UIKit
import ObjectiveC

private var actionHandlerKey = "actionHandlerKey"

extension UIView {
    /// The `ActionHandler` the receiver should send its actions to.
    ///
    /// Set the corresponding `actionHandler` property on the view controller
    /// that owns the view tree containing the receiver to make it accessible
    /// here.
    internal(set) public var actionHandler: ActionHandler? {
        get {
            return objc_getAssociatedObject(self, &actionHandlerKey) as? ActionHandler ?? superview?.actionHandler
        }
        set {
            objc_setAssociatedObject(self, &actionHandlerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
