import ObjectiveC
import UIKit

private var actionTargetKey = "actionTargetKey"

extension UIBarButtonItem {
    private var actionTarget: ActionTarget? {
        get {
            return objc_getAssociatedObject(self, &actionTargetKey) as? ActionTarget
        }
        set {
            objc_setAssociatedObject(self, &actionTargetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public convenience init(image: UIImage?, style: UIBarButtonItem.Style, source: UIViewController, action: Action) {
        self.init(image: image, style: style, source: source, dispatch: { _ in action })
    }

    public convenience init(image: UIImage?, style: UIBarButtonItem.Style, source: UIViewController, dispatch: @escaping (UIBarButtonItem) -> Action) {
        self.init(image: image, style: style, target: nil, action: nil)

        self.dispatch(from: source, do: dispatch)
    }

    public convenience init(title: String?, style: UIBarButtonItem.Style, source: UIViewController, action: Action) {
        self.init(title: title, style: style, source: source, dispatch: { _ in action })
    }
    
    public convenience init(title: String?, style: UIBarButtonItem.Style, source: UIViewController, dispatch: @escaping (UIBarButtonItem) -> Action) {
        self.init(title: title, style: style, target: nil, action: nil)

        self.dispatch(from: source, do: dispatch)
    }
    
    public convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem, source: UIViewController, action: Action) {
        self.init(barButtonSystemItem: barButtonSystemItem, source: source, dispatch: { _ in action })
    }

    public convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem, source: UIViewController, dispatch: @escaping (UIBarButtonItem) -> Action) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)

        self.dispatch(from: source, do: dispatch)
    }

    public func `do`(closure: @escaping (UIBarButtonItem) -> Void) {
        action = #selector(ActionTarget.handle)
        actionTarget = ActionTarget(owner: self) { closure($0 as! UIBarButtonItem) }
        target = actionTarget
    }

    public func dispatch(from source: UIViewController, do closure: @escaping (UIBarButtonItem) -> Action) {
        `do` { [unowned source = source] item in
            let action = closure(item)

            source.dispatch(action)
        }
    }
}
