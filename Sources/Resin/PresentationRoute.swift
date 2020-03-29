import Foundation
import Incremental
import UIKit

/// A `PresentationRoute` is used to create a `UIViewController` for a given
/// `PresentationIdentifier` without having to know the context in which it is
/// created.
public struct PresentationRoute<Identifier: PresentationIdentifier, State: Equatable, ViewController: UIViewController> {
    private let isModal: (Identifier) -> Bool

    private let make: (Identifier, Store<State>) -> ViewController

    public init(isModal: @escaping (Identifier) -> Bool = { _ in ViewController.requiresModalPresentation }, make: @escaping (Identifier, Store<State>) -> ViewController) {
        self.isModal = isModal
        self.make = make
    }

    public func makeViewController(identifier: Identifier, store: Store<State>) -> ViewController {
        return make(identifier, store)
    }

    public func requiresModalPresentation(identifier: Identifier) -> Bool {
        return isModal(identifier)
    }
}

public extension PresentationRoute {
    var typeErased: AnyPresentationRoute<State> {
        return AnyPresentationRoute(isModal: isModal, make: make)
    }
}

extension PresentationRoute {
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> PresentationRoute<Identifier, Superstate, ViewController> {
        return PresentationRoute<Identifier, Superstate, ViewController> { identifier, store in
            self.makeViewController(identifier: identifier, store: store.focused(by: keyPath))
        }
    }
}

extension PresentationRoute where State == ArbitraryState {
    public init(isModal: @escaping (Identifier) -> Bool = { _ in ViewController.requiresModalPresentation }, make: @escaping (Identifier) -> ViewController) {
        self.make = { identifier, _ in
            make(identifier)
        }
        self.isModal = isModal
    }

    public func makeViewController(identifier: Identifier) -> ViewController {
        let store = RootStore(state: ArbitraryState())

        return make(identifier, store)
    }
}

public struct AnyPresentationRoute<State: Equatable> {
    private let isModal: (AnyPresentationIdentifier) -> Bool

    private var make: (AnyPresentationIdentifier, Store<State>) -> UIViewController

    internal var underlyingTypeIdentifier: TypeIdentifier

    internal init<N: PresentationIdentifier, V: UIViewController>(isModal: @escaping (N) -> Bool = { _ in V.requiresModalPresentation }, make: @escaping (N, Store<State>) -> V) {
        self.init(isModal: { isModal($0.underlying as! N) }, underlyingTypeIdentifier: TypeIdentifier(type: N.self), make: { make($0.underlying as! N, $1) })
    }

    private init(isModal: @escaping (AnyPresentationIdentifier) -> Bool, underlyingTypeIdentifier: TypeIdentifier, make: @escaping (AnyPresentationIdentifier, Store<State>) -> UIViewController) {
        self.isModal = isModal
        self.make = make
        self.underlyingTypeIdentifier = underlyingTypeIdentifier
    }

    public func makeViewController(identifier: AnyPresentationIdentifier, store: Store<State>) -> UIViewController {
        precondition(underlyingTypeIdentifier == identifier.underlyingTypeIdentifier)

        return make(identifier, store)
    }

    public func requiresModalPresentation(identifier: AnyPresentationIdentifier) -> Bool {
        precondition(underlyingTypeIdentifier == identifier.underlyingTypeIdentifier)

        return isModal(identifier)
    }
}

extension AnyPresentationRoute {
    public func unfocused<Superstate: Equatable>(by keyPath: WritableKeyPath<Superstate, State>) -> AnyPresentationRoute<Superstate> {
        return AnyPresentationRoute<Superstate>(isModal: isModal, underlyingTypeIdentifier: underlyingTypeIdentifier) { identifier, store in
            return self.make(identifier, store.focused(by: keyPath))
        }
    }
}

extension AnyPresentationRoute where State == ArbitraryState {
    public func makeViewController(identifier: AnyPresentationIdentifier) -> UIViewController {
        precondition(underlyingTypeIdentifier == identifier.underlyingTypeIdentifier)

        let store = RootStore(state: ArbitraryState())

        return make(identifier, store)
    }

    public func unfocused<Superstate>(to superstate: Superstate.Type = Superstate.self) -> AnyPresentationRoute<Superstate> {
        let make = self.make

        return AnyPresentationRoute<Superstate>(isModal: isModal, underlyingTypeIdentifier: underlyingTypeIdentifier) { identifier, store in
            return make(identifier, store.focused(by: ArbitraryState.arbitraryKeyPath()))
        }
    }
}
