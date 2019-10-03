import Foundation

public protocol ViewModel: Equatable {
    /// A view model that represents the empty state.
    static var empty: Self { get }

    /// This method produces a "best effort" fallback `ViewModel` in cases where
    /// the right data isn't available but a `ViewModel` is required regardless.
    ///
    /// - Parameters:
    ///   - previous: The last view model that was available.
    ///   - current:  The best view model that is available currently.
    /// - Returns: A "best effort" view model to use if no data is available or
    ///            `current` otherwise.
    static func fallback(previous: Self, current: Self?) -> Self

    /// If `true`, the view model is considered out of date and represents the
    /// last known good state.
    var isStale: Bool { get set }
}

public extension ViewModel {
    static func fallback(previous: Self, current: Self?) -> Self {
        if let current = current {
            return current
        } else {
            var copy = previous
            copy.isStale = true
            return copy
        }
    }
}

public extension ViewModel where Self: DefaultInit {
    static var empty: Self {
        return Self()
    }
}
