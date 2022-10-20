import UIKit

private var associatedObjectKey = "resin_UIGestureRecognizerActionTargetKey"

extension UIGestureRecognizer {
    private var actionTargets: [ActionTarget] {
        get {
            return objc_getAssociatedObject(self, &associatedObjectKey) as? [ActionTarget] ?? []
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func addAction(file: String =  #file, line: Int = #line, dispatch action: Action) {
        addAction(file: file, line: line) { action }
    }

    public func addAction(file: String =  #file, line: Int = #line, dispatch closure: @escaping () -> Action?) {
        let actionTarget = ActionTarget(owner: self) { gestureRecognizer in
            guard let action = closure() else { return }

            gestureRecognizer.view?.dispatch(action, file: file, line: line)
        }

        actionTargets.append(actionTarget)

        addTarget(actionTarget, action: #selector(ActionTarget.handle))
    }
}
