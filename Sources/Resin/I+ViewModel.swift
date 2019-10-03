import UIKit
import Incremental

extension I {
    /// Helper to map a state `I<A>` to an `I<ViewModel>`.
    ///
    /// The `transform` generates an optional result, in which case the result
    /// will be generated using the `ViewModel.fallback(previous:current:)`
    /// method.
    ///
    /// By default this will return a `ViewModel` with `isStale` set whenever
    /// the transform returns `nil`. If there was a previous value, that one
    /// will be returned (as stale), or if no value ever existed, `.empty` will
    /// be returned as stale.
    ///
    /// A `ViewModel` can override the `ViewModel.fallback(previous:current:)`
    /// method to provide different behaviour.
    public func mapWithFallback<B: ViewModel>(_ transform: @escaping (A) -> B?) -> I<B> {
        return map(eq: ==, transform).withFallback()
    }

    public func withFallback<V>() -> I<V> where A == V?, V: ViewModel {
        return self.reduce(V.empty, V.fallback)
    }
}
