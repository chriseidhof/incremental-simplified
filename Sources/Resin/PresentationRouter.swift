import Incremental
import UIKit

public final class PresentationRouter<State: Equatable> {
    private var routes: [TypeIdentifier: AnyPresentationRoute<State>] = [:]

    private let store: Store<State>

    public init(store: Store<State>) {
        self.store = store
    }

    public func register(route: AnyPresentationRoute<State>) {
        routes[route.underlyingTypeIdentifier] = route
    }

    public func register(routes: [AnyPresentationRoute<State>]) {
        routes.forEach { register(route: $0) }
    }

    public func register<N: PresentationIdentifier, V: UIViewController>(route: PresentationRoute<N, State, V>) {
        register(route: route.typeErased)
    }

    public func makeViewController(identifier: AnyPresentationIdentifier) -> UIViewController {
        guard let route = routes[identifier.underlyingTypeIdentifier] else {
            fatalError("No route registered for \(identifier)")
        }

        return route.makeViewController(identifier: identifier, store: store)
    }

    public func requiresModalPresentation(identifier: AnyPresentationIdentifier) -> Bool {
        guard let route = routes[identifier.underlyingTypeIdentifier] else {
            fatalError("No route registered for \(identifier)")
        }

        return route.requiresModalPresentation(identifier: identifier)
    }
}

extension PresentationRouter {
    public var typeErased: AnyPresentationRouter {
        return AnyPresentationRouter(presentationRouter: self)
    }
}

public final class AnyPresentationRouter {
    private let isModal: (AnyPresentationIdentifier) -> Bool

    private let make: (AnyPresentationIdentifier) -> UIViewController

    internal init<S: Equatable>(presentationRouter: PresentationRouter<S>) {
        isModal = presentationRouter.requiresModalPresentation
        make = presentationRouter.makeViewController
    }

    public func makeViewController(identifier: AnyPresentationIdentifier) -> UIViewController {
        return make(identifier)
    }

    public func requiresModalPresentation(identifier: AnyPresentationIdentifier) -> Bool {
        return isModal(identifier)
    }
}

extension PresentationRouter {
    public func register(delivery: Parcel<State>.Delivery) {
        delivery.presentationRoutes.forEach { route in
            register(route: route)
        }
    }
}
