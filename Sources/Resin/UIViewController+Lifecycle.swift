import Dispatch
import Foundation
import ObjectiveC
import UIKit

// Run this only once.
private let installAppearanceHooks: Void = {
    let `class`: AnyClass = objc_getClass("UIViewController") as! AnyClass

    do {
        typealias BlockSignature = @convention(block) (/* self */ UIViewController) -> Void
        typealias FunctionSignature = @convention(c) (/* self */ UIViewController, /* cmd */ Selector) -> Void

        let selector = #selector(UIViewController.viewDidLoad)

        let viewDidLoad = class_getInstanceMethod(`class`, selector)!

        let oldImplementation = unsafeBitCast(method_getImplementation(viewDidLoad), to: FunctionSignature.self)

        let newImplementation: BlockSignature = { `self` in
            oldImplementation(self, selector)

            self.whileViewIsLoadedLifecycle.start()
        }

        method_setImplementation(viewDidLoad, imp_implementationWithBlock(newImplementation))
    }

    typealias BlockSignature = @convention(block) (/* self */ UIViewController, /* animated */ Bool) -> Void
    typealias FunctionSignature = @convention(c) (/* self */ UIViewController, /* cmd */ Selector, /* animated */ Bool) -> Void

    do {
        let selector = #selector(UIViewController.viewWillAppear(_:))

        let viewWillAppear = class_getInstanceMethod(`class`, selector)!

        let oldImplementation = unsafeBitCast(method_getImplementation(viewWillAppear), to: FunctionSignature.self)

        let newImplementation: BlockSignature = { `self`, animated in
            oldImplementation(self, selector, animated)

            self.whileVisibleLifecycle.start()
        }

        method_setImplementation(viewWillAppear, imp_implementationWithBlock(newImplementation))
    }

    do {
        let selector = #selector(UIViewController.viewDidAppear(_:))

        let viewDidAppear = class_getInstanceMethod(`class`, selector)!

        let oldImplementation = unsafeBitCast(method_getImplementation(viewDidAppear), to: FunctionSignature.self)

        let newImplementation: BlockSignature = { `self`, animated in
            oldImplementation(self, selector, animated)

            self.whileAbleToPresentLifecycle.start()
        }

        method_setImplementation(viewDidAppear, imp_implementationWithBlock(newImplementation))
    }

    do {
        let selector = #selector(UIViewController.viewDidDisappear(_:))

        let viewDidDisappear = class_getInstanceMethod(`class`, selector)!

        let oldImplementation = unsafeBitCast(method_getImplementation(viewDidDisappear), to: FunctionSignature.self)

        let newImplementation: BlockSignature = { `self`, animated in
            self.whileVisibleLifecycle.stop()

            let isRootViewController = self == UIApplication.shared.keyWindow?.rootViewController

            if self.presentingViewController == nil && !isRootViewController {
                self.whileAbleToPresentLifecycle.stop()
            }

            oldImplementation(self, selector, animated)
        }

        method_setImplementation(viewDidDisappear, imp_implementationWithBlock(newImplementation))
    }
}()

public protocol UIViewControllerLifecycle: AnyObject {}

private var appearanceLifecycleKey = "appearanceLifecycle"
private var presentabilityLifecycleLifecycleKey = "inViewHierarchyLifecycle"
private var viewIsLoadedLifecycleKey = "viewIsLoadedLifecycle"

extension UIViewControllerLifecycle {
    /// A `Lifecycle` that is running as long as the receiver's able to present
    /// view controllers. Runs from `viewDidAppear(_:)` until it is removed
    /// from thew view controller hierarchy.
    public var whileAbleToPresent: Lifecycle<Self> {
        return Lifecycle<Self>(underlying: whileAbleToPresentLifecycle)
    }

    fileprivate var whileAbleToPresentLifecycle: AnyLifecycle {
        if let lifecycle = objc_getAssociatedObject(self, &presentabilityLifecycleLifecycleKey) as? AnyLifecycle {
            return lifecycle
        }

        installAppearanceHooks

        let lifecycle = AnyLifecycle(owner: self)

        objc_setAssociatedObject(self, &presentabilityLifecycleLifecycleKey, lifecycle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return lifecycle
    }

    /// A `Lifecycle` that is running as long as the receiver's view is loaded,
    /// as determined by `viewDidLoad(_:)`, and until the receiver is
    /// deallocated.
    public var whileViewIsLoaded: Lifecycle<Self> {
        return Lifecycle<Self>(underlying: whileViewIsLoadedLifecycle)
    }

    fileprivate var whileViewIsLoadedLifecycle: AnyLifecycle {
        if let lifecycle = objc_getAssociatedObject(self, &viewIsLoadedLifecycleKey) as? AnyLifecycle {
            return lifecycle
        }

        installAppearanceHooks

        let lifecycle = AnyLifecycle(owner: self)

        if (self as! UIViewController).isViewLoaded {
            lifecycle.start()
        }

        objc_setAssociatedObject(self, &viewIsLoadedLifecycleKey, lifecycle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return lifecycle
    }

    /// A `Lifecycle` that is running as long as the receiver's view is visible,
    /// as determined by the calls to `viewWillAppear(_:)` and
    /// `viewDidDisappear(_:)`.
    public var whileVisible: Lifecycle<Self> {
        return Lifecycle<Self>(underlying: whileVisibleLifecycle)
    }

    fileprivate var whileVisibleLifecycle: AnyLifecycle {
        if let lifecycle = objc_getAssociatedObject(self, &appearanceLifecycleKey) as? AnyLifecycle {
            return lifecycle
        }

        installAppearanceHooks

        let lifecycle = AnyLifecycle(owner: self)

        objc_setAssociatedObject(self, &appearanceLifecycleKey, lifecycle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return lifecycle
    }
}

extension UIViewController: UIViewControllerLifecycle {}
