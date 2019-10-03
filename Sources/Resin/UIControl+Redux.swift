import ObjectiveC
import UIKit

private var associatedObjectKey = "resin_UIControlActionTargetKey"

public protocol UIControlProtocol: AnyObject {
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event)
}

extension UIControlProtocol {
    private var actionTargets: [ActionTarget] {
        get {
            return objc_getAssociatedObject(self, &associatedObjectKey) as? [ActionTarget] ?? []
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func on(_ events: UIControl.Event, do closure: @escaping (Self) -> Void) {
        let actionTarget = ActionTarget(owner: self) { control in closure(control as! Self) }

        actionTargets.append(actionTarget)

        addTarget(actionTarget, action: #selector(ActionTarget.handle), for: events)
    }
}

extension UIControl: UIControlProtocol {
    public func on(_ events: UIControl.Event, file: String =  #file, line: Int = #line, dispatch action: Action) {
        on(events, file: file, line: line) { action }
    }

    public func on(_ events: UIControl.Event, file: String =  #file, line: Int = #line, dispatch closure: @escaping () -> Action?) {
        on(events) { control in
            guard let action = closure() else { return }

            control.dispatch(action, file: file, line: line)
        }
    }

    public func on<N: PresentationIdentifier>(_ events: UIControl.Event, file: String =  #file, line: Int = #line, push identifier: N) {
        on(events, file: file, line: line, push: identifier.typeErased)
    }

    public func on(_ events: UIControl.Event, file: String =  #file, line: Int = #line, push identifier: AnyPresentationIdentifier) {
        on(events, file: file, line: line, dispatch: ImplicitPresentationAction.push(identifier))
    }
}
