import Incremental
import UIKit

public final class ViewControllerCache {
    internal struct ControllerItemAssociation: Equatable {
        var controller: UIViewController
        var item: AnyPresentationIdentifier

        static func == (lhs: ControllerItemAssociation, rhs: ControllerItemAssociation) -> Bool {
            return lhs.controller === rhs.controller && lhs.item == rhs.item
        }
    }

    private var currentControllers: [ControllerItemAssociation] = []

    unowned let owner: UIViewController

    public init(owner: UIViewController) {
        self.owner = owner
    }

    private func makeController(index: Int, identifier: AnyPresentationIdentifier) -> ControllerItemAssociation? {
        // If the controller at the given index is already of the correct type,
        // nothing needs to be done.
        if currentControllers.indices.contains(index) && currentControllers[index].item == identifier {
            return currentControllers[index]
        }

        guard let controller = owner.presentationRouter?.makeViewController(identifier: identifier) else {
            return nil
        }

        return ControllerItemAssociation(controller: controller, item: identifier)
    }

    public func createViewControllersIfNeeded(presentationIdentifiers: [AnyPresentationIdentifier]) -> [UIViewController] {
        let associations = presentationIdentifiers.enumerated().compactMap(makeController)

        defer {
            currentControllers = associations
        }

        return associations.map { $0.controller }
    }
}
