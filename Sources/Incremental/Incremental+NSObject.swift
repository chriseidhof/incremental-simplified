import Foundation


// Could this be in a conditional block? Only works for Foundation w/ ObjC runtime
extension NSObjectProtocol where Self: NSObject {
    public subscript<Value>(_ keyPath: KeyPath<Self, Value>) -> I<Value> where Value: Equatable {
        let i: I<Value> = I(value: self[keyPath: keyPath])
        let observation = observe(keyPath) { (obj, change) in
            i.write(obj[keyPath: keyPath])
        }
        i.strongReferences.add(observation)
        return i
    }
}

public final class IBox<V>: Equatable {    
    public private(set) var unbox: V
    public var disposables: [Any] = []
    
    public init(_ object: V) {
        self.unbox = object
    }
    
    public func bind<A>(_ value: I<A>, to: WritableKeyPath<V,A>) {
        disposables.append(value.observe { [unowned self] in
            self.unbox[keyPath: to] = $0
        })
    }
    
    public func bind<A>(_ value: I<A>, to: WritableKeyPath<V,A?>) where A: Equatable {
        disposables.append(value.observe { [unowned self] in
            self.unbox[keyPath: to] = $0
        })
    }
    
    public func observe<A>(value: I<A>, onChange: @escaping (V,A) -> ()) {
        disposables.append(value.observe { newValue in
            onChange(self.unbox,newValue) // ownership?
        })
    }

    public static func ==(lhs: IBox<V>, rhs: IBox<V>) -> Bool {
        return lhs === rhs
    }
    
    /// This also copies the `disposables`
    public func map<B>(_ transform: (V) -> B) -> IBox<B> {
        let result = IBox<B>(transform(unbox))
        result.disposables.append(self)
        return result
    }
}


extension IBox where V: NSObject {
    public subscript<A>(keyPath: KeyPath<V,A>) -> I<A> where A: Equatable {
        get {
            return unbox[keyPath]
        }
    }

    public func withContents(block: (V) -> Void) {
        block(unbox)
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// One-way binding
    public func bind<Value>(keyPath: ReferenceWritableKeyPath<Self, Value>, to i: I<Value>) -> Disposable {
        return i.observe { [weak self] in
            self?[keyPath: keyPath] = $0
        }
    }

    public func bind<Value>(keyPath: ReferenceWritableKeyPath<Self, Value?>, to i: I<Value>) -> Disposable {
        return i.observe { [weak self] in
            self?[keyPath: keyPath] = $0
        }
    }
}
