import Foundation
import Incremental
import Resin
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    struct NavigationIdentifier: Resin.PresentationIdentifier {}
    
    private var viewControllerCache: ViewControllerCache!

    public init(tabs: I<[AnyPresentationIdentifier]>) {
        super.init(nibName: nil, bundle: nil)

        delegate = self

        viewControllerCache = ViewControllerCache(owner: self)

        whileVisible.do {
            $0.bind(keyPath: \.viewControllers, to: tabs.map(self.viewControllerCache.createViewControllersIfNeeded))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tab = AppState.Tab(rawValue: selectedIndex) ?? .underground
        dispatch(SetTabAction(tab: tab))
    }
}

extension TabBarController {
    struct PresentationIdentifier: Resin.PresentationIdentifier {
    }
    
    static var presentationRoute: PresentationRoute<PresentationIdentifier, AppState, TabBarController> {
        return PresentationRoute { _, store in
            let tabs: [AnyPresentationIdentifier] = [
                StationListViewController.NavigationPresentationIdentifier().typeErased,
            ]
            
            let controller = TabBarController(tabs: I(constant: tabs))
            
            controller.whileVisible.do { controller in
                controller.bind(keyPath: \.selectedIndex, to: store.state[\.selectedTab.rawValue])
            }
            
            controller.whileAbleToPresent.do { controller in
                controller.bindPresentedViewControllers(store: store, navigationStack: \.modalStack)
            }

            return controller
        }
    }
}
