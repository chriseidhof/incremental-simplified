import Foundation

private var deallocationLifecycleKey = "deallocationLifecycleKey"

extension NSObjectProtocol {
    public var untilDeallocated: Lifecycle<Self> {
        return Lifecycle<Self>(underlying: underlyingDeallocationLifecycle)
    }

    internal var underlyingDeallocationLifecycle: AnyLifecycle {
        if let lifecycle = objc_getAssociatedObject(self, &deallocationLifecycleKey) as? AnyLifecycle {
            return lifecycle
        }

        let lifecycle = AnyLifecycle(owner: self)
        lifecycle.start()

        objc_setAssociatedObject(self, &deallocationLifecycleKey, lifecycle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return lifecycle
    }
}
