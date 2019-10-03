import Incremental
import UIKit

public extension UIViewController {
    func bindPresentedViewControllers<S: Equatable>(store: Store<S>, navigationStack keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) -> Disposable {
        precondition(presentationIdentifiersKeyPath == nil, "Presented view controllers are already bound.")

        self.presentationIdentifiersKeyPath = store.keyPath.appending(path: keyPath)

        let identifiers = store.state[keyPath]

        return [
            identifiers
                .map(self.presentationViewControllerCache.createViewControllersIfNeeded)
                .observe { viewControllers in
                    let keyPath = self.presentationIdentifiersKeyPath

                    /// In order to keep the navigation stack in sync with the
                    /// modal presentation, dispatch a
                    /// `SynchronousPresentationAction` whenever one of the view
                    /// controllers gets dismissed.
                    viewControllers.enumerated().forEach { (index, viewController) in
                        let synchronousAction = SynchronousPresentationAction(popToTargetCount: index, from: keyPath!)

                        viewController.onDismiss = { [unowned viewController] in
                            viewController.dispatchWithSynchronousExecution(synchronousAction)
                        }
                    }

                    self.present(viewControllers: viewControllers, animated: true)
                },
            Disposable {
                self.presentationIdentifiersKeyPath = nil
            }
        ]
    }
}

// Run this only once.
private let installDisappearanceHooks: Void = {
    typealias BlockSignature = @convention(block) (/* self */ UIViewController, /* animated */ Bool) -> Void
    typealias FunctionSignature = @convention(c) (/* self */ UIViewController, /* cmd */ Selector, /* animated */ Bool) -> Void

    let `class`: AnyClass = objc_getClass("UIViewController") as! AnyClass

    do {
        let viewDidDisappear = class_getInstanceMethod(`class`, #selector(UIViewController.viewDidDisappear(_:)))!

        let oldImplementation = unsafeBitCast(method_getImplementation(viewDidDisappear), to: FunctionSignature.self)

        let newImplementation: BlockSignature = { `self`, animated in
            if self.presentingViewController == nil {
                self.onDismiss?()
                self.onDismiss = nil
            }

            oldImplementation(self, #selector(UIViewController.viewDidDisappear(_:)), animated)
        }

        method_setImplementation(viewDidDisappear, imp_implementationWithBlock(newImplementation))
    }
}()

private var onDismissKey = "onDismissKey"
private var presentationIdentifiersKeyPathKey = "presentationIdentifiersKeyPathKey"
private var presentationViewControllerCacheKey = "presentationViewControllerCacheKey"

extension UIViewController {
    var onDismiss: (() -> ())? {
        get {
            installDisappearanceHooks

            return objc_getAssociatedObject(self, &onDismissKey) as? () -> ()
        }
        set {
            installDisappearanceHooks

            objc_setAssociatedObject(self, &onDismissKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    var presentationIdentifiersKeyPath: AnyKeyPath? {
        get {
            return objc_getAssociatedObject(self, &presentationIdentifiersKeyPathKey) as? AnyKeyPath
        }
        set {
            objc_setAssociatedObject(self, &presentationIdentifiersKeyPathKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var presentationViewControllerCache: ViewControllerCache {
        get {
            if let cache = objc_getAssociatedObject(self, &presentationViewControllerCacheKey) as? ViewControllerCache {
                return cache
            }

            let cache = ViewControllerCache(owner: self)

            self.presentationViewControllerCache = cache

            return cache
        }
        set {
            objc_setAssociatedObject(self, &presentationViewControllerCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {
    var resolvedPresentationKeyPath: AnyKeyPath? {
        // Walk up the modal presentation chain first, as we assume that there
        // are no two view controllers that bind modal presentation on top of
        // each other.
        return presentingViewController?.resolvedPresentationKeyPath
            // If we're bound ourselves, return our
            // `presentationIdentifiersKeyPath`.
            ?? presentationIdentifiersKeyPath
            // Otherwise, recursively ask the parent.
            ?? parent?.resolvedPresentationKeyPath
    }
}

private extension UIViewController {
    func present(viewControllers: [UIViewController], animated: Bool) {
        guard !viewControllers.isEmpty else {
            if presentedViewController != nil {
                dismiss(animated: animated)
            }
            return
        }

        let toBePresented = viewControllers.first!

        guard presentedViewController != toBePresented else {
            toBePresented.present(viewControllers: Array(viewControllers.dropFirst()), animated: animated)
            return
        }

        // If presenting multiple view conrollers at once, only animate the
        // presentation of the last view controller.
        //
        // This prevents loading issues in `SFSafariViewController`.
        let actuallyAnimated = animated && viewControllers.count == 1

        if presentedViewController != nil {
            presentedViewController?.actionHandler = nil
            presentedViewController?.presentationRouter = nil

            dismiss(animated: actuallyAnimated) {
                self.present(viewControllers: viewControllers, animated: animated)
            }
        } else {
            toBePresented.actionHandler = actionHandler
            toBePresented.presentationRouter = presentationRouter

            self.present(toBePresented, animated: actuallyAnimated) {
                toBePresented.present(viewControllers: Array(viewControllers.dropFirst()), animated: animated)
            }
        }
    }
}
