import Dispatch
import Incremental

private protocol AnyStore: ActionHandler {
    var keyPath: AnyKeyPath { get }
}

/// A `Store` offers a way to subscribe to a `State` and handles updates to it
/// using `Reducer`s.
public class Store<State: Equatable>: AnyStore {
    public let state: I<State>

    public let keyPath: AnyKeyPath

    private let parent: AnyStore?

    fileprivate init(state: I<State>, parent: AnyStore!, keyPath: AnyKeyPath) {
        self.state = state
        self.parent = parent
        self.keyPath = keyPath
    }

    /// Handles an Action.
    ///
    /// - Parameters:
    ///   - action: The action to handle, if no `Reducer` is set up for this
    ///             `Action` type, an error will be logged.
    public func handle(_ action: Action, context: ActionContext) {
        parent!.handle(action, context: context)
    }

    /// Creates a new Store that focuses on a part of the receiver's State.
    ///
    /// This method allows us to pass up Stores focused on the most specific
    /// state that other components need to care about.
    ///
    /// The resulting store forwards all actions to the receiver.
    ///
    /// - Parameters:
    ///   - by: A `KeyPath` that maps from the state of the receiver to a more
    ///         specific substate.
    public func focused<Substate: Equatable>(by keyPath: WritableKeyPath<State, Substate>) -> Store<Substate> {
        let combined = self.keyPath.appending(path: keyPath)!

        return Store<Substate>(state: state[keyPath], parent: self, keyPath: combined)
    }
}

/// A `Store` can be in direct control of the middleware, reducers and state
/// or be a proxy of a different store.
///
/// This allows us to give separate components a different view on the same
/// data.
public final class RootStore<State: Equatable>: Store<State> {
    var middleware: [AnyMiddleware<State>] = []

    var reducers: [TypeIdentifier: AnyReducer<State>] = [:]

    private let stateInput: Input<State>

    private var isCurrentlyExecutingAction = false

    private var underlyingState: State {
        didSet {
            stateInput.write(underlyingState)
        }
    }

    /// Initializes a store.
    ///
    /// - Parameters:
    ///   - state: The initial state of the store. All further modifications to
    ///            this state will be made by handling actions.
    public init(state: State) {
        self.stateInput = Input(state)
        self.underlyingState = state

        super.init(state: stateInput.i, parent: nil, keyPath: \State.self)
    }

    public func add(middleware: AnyMiddleware<State>) {
        middleware.actionHandler = self

        self.middleware.append(middleware)
    }

    public func add(reducer: AnyReducer<State>) {
        reducers[reducer.actionIdentifier] = reducer
    }

    public override func handle(_ action: Action, context: ActionContext) {
        guard !isCurrentlyExecutingAction else {
            print("Error: Action caused another Action to dispatch before completing")
            return
        }

        isCurrentlyExecutingAction = true
        defer {
            isCurrentlyExecutingAction = false
        }

        print("Handling action \(type(of: action))")

        // Run our Action through the middleware, if at any step action gets
        // caught, abort.
        let transformedAction: Action? = middleware.reduce(action as Action?) { action, middle in
            guard let action = action else { return nil }

            return middle.transform(action: action, context: context, state: underlyingState)
        }

        guard let action = transformedAction else { return }

        /// If an action makes it past the Middleware, it needs to be handled on
        /// the main queue.
        dispatchPrecondition(condition: .onQueue(.main))

        guard let reducer = reducers[TypeIdentifier(value: action)] else {
            print("Action dispatched in \(context.file):\(context.line) was not handled.")
            return
        }

        reducer.reduce(action: action, state: &underlyingState)
    }
}
