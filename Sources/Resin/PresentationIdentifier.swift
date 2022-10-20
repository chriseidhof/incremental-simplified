import UIKit

/// A `PresentationIdentifier` identifies a target that can be navigated to,
/// e.g. using a `UINavigationController`.
public protocol PresentationIdentifier: Equatable {}

public extension PresentationIdentifier {
    var typeErased: AnyPresentationIdentifier {
        return AnyPresentationIdentifier(presentationIdentifier: self)
    }
}

/// A type-erased presentation identifier.
public struct AnyPresentationIdentifier: Equatable {
    private let equal: (Any) -> Bool

    internal let underlying: Any

    internal let underlyingTypeIdentifier: TypeIdentifier

    internal init<N: PresentationIdentifier>(presentationIdentifier: N) {
        equal = { rhs in
            guard let other = rhs as? N else { return false }

            return presentationIdentifier == other
        }

        underlying = presentationIdentifier
        underlyingTypeIdentifier = TypeIdentifier(value: presentationIdentifier)
    }

    public static func == (lhs: AnyPresentationIdentifier, rhs: AnyPresentationIdentifier) -> Bool {
        return lhs.equal(rhs.underlying)
    }
}
