import UIKit

public struct ActionContext {
    public var file: String

    public var line: Int

    public var view: UIView?

    public var viewController: UIViewController?

    public init(file: String, line: Int, view: UIView? = nil, viewController: UIViewController? = nil) {
        self.file = file
        self.line = line
        self.view = view
        self.viewController = viewController
    }
}
