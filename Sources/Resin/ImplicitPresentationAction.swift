import Incremental

public struct ImplicitPresentationAction: Action {
    enum Presentation {
        case push(AnyPresentationIdentifier)
        case pop
        case popSpecific(AnyPresentationIdentifier)

        @available(*, deprecated, message: "This will be removed in the future.")
        case replaceTop(AnyPresentationIdentifier)
    }

    var presentation: Presentation

    public static func pop<N: PresentationIdentifier>(_ identifier: N? = nil) -> ImplicitPresentationAction {
        return pop(identifier?.typeErased)
    }

    public static func pop(_ identifier: AnyPresentationIdentifier? = nil) -> ImplicitPresentationAction {
        return ImplicitPresentationAction(presentation: identifier.map(Presentation.popSpecific) ?? .pop)
    }

    public static func push<N: PresentationIdentifier>(_ identifier: N) -> ImplicitPresentationAction {
        return push(identifier.typeErased)
    }

    public static func push(_ identifier: AnyPresentationIdentifier) -> ImplicitPresentationAction {
        return ImplicitPresentationAction(presentation: .push(identifier))
    }

    @available(*, deprecated, message: "This will be removed in the future.")
    public static func replaceTop<N: PresentationIdentifier>(_ identifier: N) -> ImplicitPresentationAction {
        return replaceTop(identifier.typeErased)
    }

    @available(*, deprecated, message: "This will be removed in the future.")
    public static func replaceTop(_ identifier: AnyPresentationIdentifier) -> ImplicitPresentationAction {
        return ImplicitPresentationAction(presentation: .replaceTop(identifier))
    }
}

internal final class ImplicitPresentationMiddleware: Middleware<ImplicitPresentationAction, ArbitraryState> {
    override func transform(action: ImplicitPresentationAction, context: ActionContext, state: ArbitraryState) -> Action? {
        guard let viewController = context.viewController else {
            fatalError("Action \(action) was not dispatched from a view controller context in \(context.file):\(context.line).")
        }

        // TODO: We should inject the presentation router here through whatever
        //       dependency mechanism we come up with.
        let presentationRouter = viewController.presentationRouter!

        let requiresModalPresentation: Bool

        switch action.presentation {
        case .pop:
            requiresModalPresentation = type(of: viewController).requiresModalPresentation
        case .popSpecific(let identifier):
            requiresModalPresentation = presentationRouter.requiresModalPresentation(identifier: identifier)
        case .push(let identifier):
            requiresModalPresentation = presentationRouter.requiresModalPresentation(identifier: identifier)
        case .replaceTop(let identifier):
            requiresModalPresentation = presentationRouter.requiresModalPresentation(identifier: identifier)
        }

        /// TODO: This mechanism shouldn't use the navigation controller but
        ///       instead use something like
        //        `targetViewController(forAction:sender:)`.
        let presentationKeyPath = requiresModalPresentation ? nil : viewController.navigationController?.navigationIdentifiersKeyPath

        guard let targetKeyPath = presentationKeyPath ?? viewController.resolvedPresentationKeyPath else {
            return nil
        }

        let presentationAction: PresentationAction

        switch action.presentation {
        case .pop:
            presentationAction = PresentationAction(popFrom: targetKeyPath)
        case .popSpecific(let identifier):
            presentationAction = PresentationAction(popFrom: targetKeyPath, identifier: identifier)
        case .push(let identifier):
            presentationAction = PresentationAction(push: identifier, onto: targetKeyPath)
        case .replaceTop(let identifier):
            presentationAction = PresentationAction(replaceTopWith: identifier, onto: targetKeyPath)
        }

        dispatch(presentationAction, context: context)

        return nil
    }
}

public extension RootStore {
    /// TODO: We should probably just install this by default.
    func addImplicitNavigationMiddleware() {
        add(middleware: ImplicitPresentationMiddleware().unfocused())
    }
}
