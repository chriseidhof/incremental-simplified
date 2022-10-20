import Foundation
import Incremental
import Resin
import UIKit

final class ForegroundDaemon: Daemon<ArbitraryState> {
    public override func observe(state: I<ArbitraryState>) -> Disposable? {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observe(note:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return nil
    }
    
    @objc
    func observe(note: Notification) {
        dispatch(LoadStationsAction())
    }
}
