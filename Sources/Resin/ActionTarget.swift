import Foundation

final class ActionTarget: NSObject {
    let closure: (AnyObject) -> Void

    unowned let owner: AnyObject

    init(owner: AnyObject, closure: @escaping (AnyObject) -> Void) {
        self.closure = closure
        self.owner = owner
    }

    @objc
    func handle() {
        closure(owner)
    }
}
