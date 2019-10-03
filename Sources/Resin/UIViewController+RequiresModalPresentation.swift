import UIKit
import SafariServices

extension SFSafariViewController {
    @objc override open class var requiresModalPresentation: Bool {
        return true
    }
}

extension UIActivityViewController {
    @objc override open class var requiresModalPresentation: Bool {
        return true
    }
}

extension UINavigationController {
    @objc override open class var requiresModalPresentation: Bool {
        return true
    }
}

extension UIViewController {
    @objc open class var requiresModalPresentation: Bool {
        return false
    }
}
