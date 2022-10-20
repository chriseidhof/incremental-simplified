import Incremental

extension Disposable: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Disposable...) {
        var disposables = elements

        self.init {
            disposables = []
            _ = disposables
        }
    }
}
