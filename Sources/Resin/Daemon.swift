import Foundation
import Incremental

/// A `Daemon` offers a way to observe  `State` instead of catching an `Action`
///
/// Usually used for background processing, such as ensuring some outside system remains
/// in sync with `State`.
open class Daemon<State: Equatable>: AnyMiddleware<State> {
    private var disposable: Disposable?
    
    private let state: I<State>
    
    public init(state: I<State>) {
        self.state = state
                
        super.init()
    }
    
    open func observe(state: I<State>) -> Disposable? {
        return nil
    }

    override public var actionHandler: ActionHandler? {
        willSet {
            stop()
        }
        didSet {
            guard actionHandler != nil else { return }
            
            start()
        }
    }

    open func start() {
        disposable = observe(state: state)
    }

    open func stop() {
        disposable = nil
    }
}
