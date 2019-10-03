import Foundation

public struct PresentationAction: Action {
    public enum Presentation: Equatable {
        case force([AnyPresentationIdentifier])
        case pop
        case popSpecific(AnyPresentationIdentifier)
        case popToTargetCount(Int)
        case push(AnyPresentationIdentifier)

        @available(*, deprecated, message: "This will be removed in the future.")
        case replace(AnyPresentationIdentifier) // Replaces top PresentationIdentifier
    }

    public var presentation: Presentation

    public var target: AnyKeyPath

    public init<N: PresentationIdentifier, S: Equatable>(push identifier: N, onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        self.init(push: identifier.typeErased, onto: keyPath as AnyKeyPath)
    }

    public init<S: Equatable>(push identifier: AnyPresentationIdentifier, onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        self.init(push: identifier, onto: keyPath as AnyKeyPath)
    }

    public init(push identifier: AnyPresentationIdentifier, onto keyPath: AnyKeyPath) {
        precondition(type(of: keyPath).valueType is [AnyPresentationIdentifier].Type)

        presentation = .push(identifier)
        target = keyPath
    }

    public init<S: Equatable>(popFrom keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>, identifier: AnyPresentationIdentifier? = nil) {
        self.init(popFrom: keyPath as AnyKeyPath)
    }

    public init(popFrom keyPath: AnyKeyPath, identifier: AnyPresentationIdentifier? = nil) {
        presentation = identifier.map(Presentation.popSpecific) ?? .pop
        target = keyPath
    }

    public init<S: Equatable>(popToTargetCount count: Int, from keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        presentation = .popToTargetCount(count)
        target = keyPath
    }

    public init<S: Equatable>(force identifiers: [AnyPresentationIdentifier], onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        presentation = .force(identifiers)
        target = keyPath
    }

    @available(*, deprecated, message: "This will be removed in the future.")
    public init<N: PresentationIdentifier, S: Equatable>(replaceTopWith identifier: N, onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        self.init(replaceTopWith: identifier.typeErased, onto: keyPath as AnyKeyPath)
    }

    @available(*, deprecated, message: "This will be removed in the future.")
    public init<S: Equatable>(replaceTopWith identifier: AnyPresentationIdentifier, onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        self.init(replaceTopWith: identifier, onto: keyPath as AnyKeyPath)
    }

    @available(*, deprecated, message: "This will be removed in the future.")
    public init(replaceTopWith identifier: AnyPresentationIdentifier, onto keyPath: AnyKeyPath) {
        precondition(type(of: keyPath).valueType is [AnyPresentationIdentifier].Type)

        presentation = .replace(identifier)
        target = keyPath
    }

    public init<N: PresentationIdentifier, S: Equatable>(force identifiers: [N], onto keyPath: WritableKeyPath<S, [AnyPresentationIdentifier]>) {
        self.init(force: identifiers.map { $0.typeErased }, onto: keyPath)
    }
}

internal struct PresentationReducer<State: Equatable>: Reducer {
    // swiftlint:disable:next cyclomatic_complexity
    public func reduce(action: PresentationAction, state: inout State) {
        guard let keyPath = action.target as? WritableKeyPath<State, [AnyPresentationIdentifier]> else {
            print("Target key path %@ is not compatible with %@", "\(action.target)", "\(State.self)")
            return
        }

        var stack: [AnyPresentationIdentifier] {
            get {
                return state[keyPath: keyPath]
            }
            set {
                state[keyPath: keyPath] = newValue
            }
        }

        switch action.presentation {
        case .force(let identifiers):
            stack = identifiers
        case .pop:
            guard !stack.isEmpty else {
                print("Couldn't pop from %@", "\(action.target)")
                return
            }

            stack.removeLast()
        case .popSpecific(let identifier):
            if stack.last == identifier {
                stack.removeLast()
            }
        case .popToTargetCount(let count):
            guard stack.count >= count else {
                print("Couldn't pop to target count from %@", "\(action.target)")
                return
            }

            stack.removeLast(stack.count - count)
        case .push(let identifier):
            stack.append(identifier)
        case .replace(let identifier):
            guard !stack.isEmpty else {
                print("No identifiers to replace from %@", "\(action.target)")
                return
            }

            stack[stack.count - 1] = identifier
        }
    }
}

/// Used exclusively to catch state up with UIKit.
///
/// For example, when a back button is pressed in UINavigationController
/// this can be called from navigationController:didShow:animated: to sync state.
public struct SynchronousPresentationAction: SystemResponseAction {
    public enum Presentation {
        case popToTargetCount(Int)
    }

    public var presentation: Presentation

    public var target: AnyKeyPath

    public init(popToTargetCount count: Int, from keyPath: AnyKeyPath) {
        presentation = .popToTargetCount(count)
        target = keyPath
    }
}

internal struct SynchronousPresentationReducer<State: Equatable>: Reducer {
    public func reduce(action: SynchronousPresentationAction, state: inout State) {
        switch action.presentation {
        case .popToTargetCount(let count):
            guard let keyPath = action.target as? WritableKeyPath<State, [AnyPresentationIdentifier]> else {
                print("Target key path %@ is not compatible with %@", "\(action.target)", "\(State.self)")
                return
            }

            guard state[keyPath: keyPath].count >= count else {
                print("Couldn't pop to target count from %@", "\(action.target)")
                return
            }

            state[keyPath: keyPath].removeLast(state[keyPath: keyPath].count - count)
        }
    }
}

public extension RootStore {
    /// TODO: We should probably just install these by default.
    func addPresentationReducers() {
        add(reducer: PresentationReducer<State>().typeErased)
        add(reducer: SynchronousPresentationReducer<State>().typeErased)
    }
}
