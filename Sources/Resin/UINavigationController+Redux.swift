import Incremental
import UIKit

private var navigationDelegateProxyKey = "navigationDelegateProxyKey"
private var navigationViewControllerCacheKey = "navigationViewControllerCacheKey"
private var navigationIdentifiersKeyPathKey = "navigationIdentifiersKeyPathKey"

extension UINavigationController {
    fileprivate var navigationDelegateProxy: NavigationDelegateProxy? {
        get {
            return objc_getAssociatedObject(self, &navigationDelegateProxyKey) as? NavigationDelegateProxy
        }
        set {
            objc_setAssociatedObject(self, &navigationDelegateProxyKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var navigationIdentifiersKeyPath: AnyKeyPath? {
        get {
            return objc_getAssociatedObject(self, &navigationIdentifiersKeyPathKey) as? AnyKeyPath
        }
        set {
            objc_setAssociatedObject(self, &navigationIdentifiersKeyPathKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private(set) internal var navigationViewControllerCache: ViewControllerCache {
        get {
            if let cache = objc_getAssociatedObject(self, &navigationViewControllerCacheKey) as? ViewControllerCache {
                return cache
            }

            let cache = ViewControllerCache(owner: self)

            self.navigationViewControllerCache = cache

            return cache
        }
        set {
            objc_setAssociatedObject(self, &navigationViewControllerCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public convenience init<S: Equatable>(store: Store<S>, root: AnyPresentationIdentifier? = nil, navigationStack keyPath: KeyPath<S, [AnyPresentationIdentifier]>) {
        self.init()

        self.navigationIdentifiersKeyPath = store.keyPath.appending(path: keyPath)
        self.navigationDelegateProxy = NavigationDelegateProxy()

        self.delegate = self.navigationDelegateProxy

        let identifiers = store.state[keyPath]
            .map { ids -> [AnyPresentationIdentifier] in
                if let r = root {
                    return [r] + ids
                } else {
                    return ids
                }
            }

        whileVisible.do { navigationController in
            let _navigationController = navigationController

            return identifiers
                .map(_navigationController.navigationViewControllerCache.createViewControllersIfNeeded)
                .observe { [unowned _navigationController] viewControllers in
                    let inTransition = _navigationController.isBeingPresented || _navigationController.isBeingDismissed
                    let isVisible = _navigationController.viewIfLoaded?.window != nil

                    let animated = !inTransition && isVisible

                    if animated && _navigationController.viewControllers == Array(viewControllers.dropLast()) {
                        _navigationController.pushViewController(viewControllers.last!, animated: animated)
                    } else {
                        _navigationController.setViewControllers(viewControllers, animated: animated)
                    }
                }
        }
    }
}

private class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let targetCount = navigationController.viewControllers.count - 1

        guard let target = navigationController.navigationIdentifiersKeyPath else { return }

        let action = SynchronousPresentationAction(popToTargetCount: targetCount, from: target)

        navigationController.dispatchWithSynchronousExecution(action)
    }
}
