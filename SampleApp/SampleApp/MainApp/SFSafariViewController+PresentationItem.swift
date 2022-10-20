import Resin
import SafariServices

extension SFSafariViewController {
    public struct PresentationIdentifier: Resin.PresentationIdentifier {
        public var url: URL

        public init(url: URL) {
            self.url = url
        }
    }
    
    static var presentationRoute: PresentationRoute<PresentationIdentifier, ArbitraryState, SFSafariViewController> {
        return PresentationRoute { identifier, _ in
            SFSafariViewController(url: identifier.url)
        }
    }
}
