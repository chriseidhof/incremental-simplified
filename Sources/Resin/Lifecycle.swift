import Foundation
import Incremental

/// A `Lifecycle` can be used to manage bindings on an object that should be
/// limited to certain parts of its life-cycle.
///
/// For example, most view bindings only need to be active while a view
/// controller is visible. A `Lifecycle` can be used to automatically create
/// the necessary bindings when the view appears and to dispose of them when the
/// view disappears.
///
/// It is parameterized by `OwnerType`, which is the type of object the
/// lifecycle belongs to.
public final class Lifecycle<OwnerType: AnyObject> {
    internal var underlying: AnyLifecycle

    /// Initializes the Lifecycle with a type-erased `AnyLifecycle`.
    ///
    /// You need to make sure that the owner of the underlying `AnyLifecycle`
    /// is type-compatible with `OwnerType`.
    public init(underlying: AnyLifecycle) {
        self.underlying = underlying
    }

    /// Adds a binding to the Lifecycle.
    ///
    /// The binding will be executed whenever the Lifecycle is running or
    /// immediately if that is already the case.
    public func `do`(closure: @escaping (OwnerType) -> Disposable) {
        underlying.add { owner in
            [closure(owner as! OwnerType)]
        }
    }
}

/// A type-erased Lifecycle.
public final class AnyLifecycle {
    internal var closures: [(AnyObject) -> [Disposable]] = []

    internal var disposables: [Disposable] = []

    internal var isRunning: Bool = false

    internal unowned let owner: AnyObject

    /// Initializes the `AnyLifecycle` with an object it will keep an unowned
    /// reference to.
    public init(owner: AnyObject) {
        self.owner = owner
    }

    internal func add(closure: @escaping (AnyObject) -> [Disposable]) {
        closures.append(closure)

        if isRunning {
            disposables.append(contentsOf: closure(owner))
        }
    }

    /// Starts the lifecycle, creating the bindings if necessary.
    public func start() {
        guard !isRunning else { return }

        disposables = closures.flatMap { $0(owner) }

        isRunning = true
    }

    /// Stops the lifecycle, disposing of all `Disposable`s that were created
    /// as necessary.
    public func stop() {
        guard isRunning else { return }

        disposables = []

        isRunning = false
    }
}
