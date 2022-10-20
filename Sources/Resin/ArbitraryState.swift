import Foundation

/// A placeholder state that can be derived from any `Equatable`.
///
/// Used for `PresentationRoute`s that don't require an explicit state.
public struct ArbitraryState: Equatable, DefaultInit {
    public init() { }

    public static func arbitraryKeyPath<S: Equatable>() -> WritableKeyPath<S, ArbitraryState> {
        return \S.arbitraryState
    }

    public static func == (lhs: ArbitraryState, rhs: ArbitraryState) -> Bool {
        return true
    }
}

private extension Equatable {
    var arbitraryState: ArbitraryState {
        get {
            return ArbitraryState()
        }
        set {}
    }
}
