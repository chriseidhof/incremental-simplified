import Resin
import SafariServices
import UIKit

typealias AppEnvironment = (
    userDefaults: UserDefaults,
    loadStations: (@escaping (Result<StationsState, Error>) -> Void) -> Void
)

public final class AppCoordinator {
    let presentationRouter: PresentationRouter<AppState>

    let tabBarController: TabBarController

    let store: Store<AppState>

    public init() {
        let store = RootStore(state: AppState())
        
        let environment: AppEnvironment = (
            userDefaults: .standard,
            loadStations: dummyLoadStations
        )
        
        self.presentationRouter = PresentationRouter(store: store)
        
        let parcels: [Parcel<AppState>] = [
            mapAppStateParcel(),
            makeUndergroundParcel(environment: environment).unfocused(by: \AppState.undergroundState),
        ]

        for p in parcels {
            let delivery = p.build(store)
            store.integrate(delivery: delivery)
            presentationRouter.register(delivery: delivery)
        }

        store.addImplicitNavigationMiddleware()
        store.addPresentationReducers()
        
        self.store = store
        
        tabBarController = presentationRouter.makeViewController(identifier: TabBarController.PresentationIdentifier().typeErased) as! TabBarController
        tabBarController.presentationRouter = presentationRouter.typeErased
        tabBarController.actionHandler = store
    }
}

func mapAppStateParcel() -> Parcel<AppState> {
    Parcel { store in
        var delivery = Parcel<AppState>.Delivery()
        
        delivery.middlewares = [
            ForegroundDaemon(state: store.state.map { _ in ArbitraryState() }).unfocused(),
        ]
        delivery.reducers = [
            SetTabReducer().typeErased,
        ]
        
        delivery.presentationRoutes = [
            SFSafariViewController.presentationRoute.typeErased.unfocused(),
            TabBarController.presentationRoute.typeErased,
        ]
        
        return delivery
    }
}
