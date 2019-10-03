import UIKit

private var presentationRouterKey = "presentationRouterKey"

extension UIViewController {
    /// The `ActionHandler` used by this view controller.
    ///
    /// It's a view controllers responsibility to bridge its child views and the
    /// `Action` infrastructure. Use this property to make an `ActionHandler`
    /// available to the entire view tree owned by the receiver.
    public var actionHandler: ActionHandler? {
        get {
            return view.actionHandler
        }
        set {
            view.actionHandler = newValue
        }
    }

    public var presentationRouter: AnyPresentationRouter? {
        get {
            return objc_getAssociatedObject(self, &presentationRouterKey) as? AnyPresentationRouter ?? parent?.presentationRouter
        }
        set {
            objc_setAssociatedObject(self, &presentationRouterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func dispatch(_ action: Action, file: String = #file, line: Int = #line) {
        let context = ActionContext(file: file, line: line, viewController: self)

        actionHandler?.dispatch(action, context: context)
    }

    public func dispatchWithSynchronousExecution(_ action: SystemResponseAction, file: String = #file, line: Int = #line) {
        let context = ActionContext(file: file, line: line, viewController: self)

        actionHandler?.dispatchWithSynchronousExecution(action, context: context)
    }
}
