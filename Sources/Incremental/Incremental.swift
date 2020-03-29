// TODO: expose an Incremental.transaction method which allows multiple writes before processing.
// This class is (by design) not thread-safe
final class Queue {
    static let shared = Queue()
    var edges: [(Edge, Height)] = []
    var processed: [Edge] = []
    var fired: [AnyI] = []
    var processing: Bool = false
    
    func enqueue<S: Sequence>(_ edges: S) where S.Element: Edge {
        enqueue(edges.lazy.map { $0 as Edge })
    }
    
    func enqueue<S: Sequence>(_ edges: S) where S.Element == Edge {
        self.edges.append(contentsOf: edges.lazy.map { ($0, $0.height) })
        self.edges.sort { $0.1 < $1.1 }
    }
    
    func fired(_ source: AnyI) {
        fired.append(source)
    }
    
    func process() {
        guard !processing else { return }
        processing = true
        while let (edge, _) = edges.popLast() {
            guard !processed.contains(where: { $0 === edge }) else {
                continue
            }
            processed.append(edge)
            edge.fire()
        }
        
        // cleanup
        for i in fired {
            i.firedAlready = false
        }
        fired = []
        processed = []
        processing = false
    }
}

protocol Node {
    var height: Height { get }
}

protocol Edge: class, Node {
    func fire()
}

final class Observer: Edge {
    let observer: () -> ()
    
    init(_ fire: @escaping  () -> ()) {
        self.observer = fire
        fire()
    }
    let height = Height.minusOne
    func fire() {
        observer()
    }
}

protocol Reader: Edge {
    var invalidated: Bool { get set }
}

class AnyReader: Reader {
    let read: () -> Node
    var height: Height {
        return target.height.incremented()
    }
    var target: Node
    var invalidated: Bool = false
    init(read: @escaping () -> Node) {
        self.read = read
        target = read()
    }

    func fire() {
        if invalidated {
            return
        }
        target = read()
    }
}

// We don't need MapReader and FlatMapReader, but could express everything in terms of AnyReader. Not sure what is better: less concepts, or more (and duplicated) but clearer code.
final class MapReader: Reader {
    let read: () -> ()
    unowned var target: AnyI
    var invalidated: Bool = false

    init<A,B>(source: I<A>, transform: @escaping (A) -> B, target: I<B>) {
        read = { [unowned target] in
            target.write(transform(source.value))
        }
        read()
        self.target = target
    }
    var height: Height {
        return target.height.incremented()
    }
    func fire() {
        if invalidated {
            return // todo dry
        }
        read()
        
    }
}

final class FlatMapReader: Reader {
    var read: (() -> ())!
    unowned var target: AnyI
    var invalidated: Bool = false {
        didSet {
            disposable = nil
            sourceNode = nil
        }
    }
    var sourceNode: AnyI!
    var token: Register<Any>.Token? = nil
    var disposable: Any?
    
    init<A,B>(source: I<A>, transform: @escaping (A) -> I<B>, target: I<B>) {
        self.target = target
        read = { [unowned target] in
            self.disposable = nil
            let newSourceNode = transform(source.value)
            self.disposable = newSourceNode.addReader(MapReader(source: newSourceNode, transform: { $0 }, target: target))
            target.write(newSourceNode.value)
            self.sourceNode = newSourceNode // todo should this be a strong reference?
        }
        read()
    }
    var height: Height {
        return sourceNode.height.incremented()
    }
    func fire() {
        if invalidated {
            return // todo dry
        }
        read()
        
    }
}


public final class Input<A> {
    public let i: I<A>
    
    public init(eq: @escaping (A,A) -> Bool, _ value: A) {
        i = I(eq: eq, value: value)
    }
    
    public init(alwaysPropagate value: A) {
        i = I(eq: { _, _ in false }, value: value)
    }
    
    public func write(_ newValue: A) {
        i.write(newValue)
    }
    
    public func change<B>(_ by: (inout A) -> B) -> B {
        var copy = i.value!
        let result = by(&copy)
        i.write(copy)
        return result
    }
    
    public subscript<B: Equatable>(keyPath: KeyPath<A,B>) -> I<B> {
        return i.map { $0[keyPath: keyPath] }
    }
}

extension Input where A: Equatable {
    public convenience init(_ value: A) {
        self.init(eq: ==, value)
    }
}


protocol AnyI: class, Node {
    var firedAlready: Bool { get set }
    var strongReferences: Register<Any> { get set }
    var height: Height { get }
}

public final class I<A>: AnyI, Node {
    internal(set) public var value: A! // todo this will not be public!
    var observers = Register<Observer>()
    var readers: Register<Reader> = Register()
    var height: Height {
        return readers.values.map { $0.height }.leastUpperBound.incremented()
    }
    var firedAlready: Bool = false
    var strongReferences: Register<Any> = Register()
    var eq: (A,A) -> Bool
    private var constant: Bool
    
    init(eq: @escaping (A, A) -> Bool, value: A) {
        self.value = value
        self.eq = eq
        self.constant = false
    }

    init(eq: @escaping (A,A) -> Bool) {
        self.eq = eq
        self.constant = false
    }
    
    public init(constant: A) {
        self.value = constant
        self.eq = { _, _ in true }
        self.constant = true
    }
    
    public func observe(_ observer: @escaping (A) -> ()) -> Disposable {
        let token = observers.add(Observer {
            observer(self.value)
        })
        return Disposable { /* should this be weak/unowned? */
            self.observers.remove(token)
        }
    }
    
    func _writeHelper(_ value: A) -> I<A> {
        if let existing = self.value, eq(existing, value) { return self }
        self.value = value

        guard !firedAlready else { return self }
        firedAlready = true
        let r: [Edge] = Array(readers.values)
        Queue.shared.enqueue(r)
        Queue.shared.enqueue(observers.values)
        Queue.shared.fired(self)
        Queue.shared.process()
        return self
    }
    /// Returns `self`
    @discardableResult
    func write(_ value: A, file: StaticString = #file, line: UInt = #line) -> I<A> {
        precondition(!constant, file: file, line: line)
        return _writeHelper(value)
    }

    @discardableResult
    func write(constant value: A, file: StaticString = #file, line: UInt = #line) -> I<A> {
        assert(!constant, file: file, line: line)
        self.constant = true // this node will never fire again
        return _writeHelper(value)
    }
    
    func addReader(_ reader: Reader) -> Disposable {
        let token = readers.add(reader)
        return Disposable {
            reader.invalidated = true
            self.readers.remove(token)
        }
    }
    
    /// The `target` strongly references the reader. If the target goes away, the reader will be removed as well.
    /// The `read` needs to return a `Node`: this is the direct dependency of the read function (used to ultimately compute the topological order).
    @discardableResult
    func read(target: AnyI, _ read: @escaping (A) -> Node) -> AnyReader {
        let reader = AnyReader { read(self.value) }
        guard !constant else {
            return reader
        }
        let disposable = addReader(reader)
        target.strongReferences.add(disposable)
        return reader
    }

    @discardableResult
    func read(_ read: @escaping (A) -> Node) -> (AnyReader, Disposable?) {
        let reader = AnyReader { read(self.value) }
        guard !constant else {
            return (reader, nil)
        }
        let disposable = addReader(reader)
        return (reader, disposable)
    }

    public func map<B>(eq: @escaping (B,B) -> Bool, _ transform: @escaping (A) -> B) -> I<B> {
        guard !constant else {
            return I<B>(constant: transform(self.value))
        }
        
        let result = I<B>(eq: eq)
        let reader = MapReader(source: self, transform: transform, target: result)
        result.strongReferences.add(addReader(reader))
        return result
    }
    
    public func flatMap<B>(eq: @escaping (B,B) -> Bool, _ transform: @escaping (A) -> I<B>) -> I<B> {
        guard !constant else {
            return transform(self.value)
        }
        let result = I<B>(eq: eq) // todo: could we somehow pull eq out of the transform's result?
        let reader = FlatMapReader(source: self, transform: transform, target: result)
        result.strongReferences.add(addReader(reader))
        return result
    }
    
    func mutate(_ transform: (inout A) -> ()) {
        var newValue = value!
        transform(&newValue)
        write(newValue)
    }
}


extension I {
    public func map<B: Equatable>(_ transform: @escaping (A) -> B) -> I<B> {
        return map(eq: ==, transform)
    }
    
    public func flatMap<B: Equatable>(_ transform: @escaping (A) -> I<B>) -> I<B> {
        return flatMap(eq: ==, transform)
    }

    public func zip2<B: Equatable,C: Equatable>(_ other: I<B>, _ with: @escaping (A,B) -> C) -> I<C> {
        return flatMap { value in other.map { with(value, $0) } }
    }
    
    public func zip3<B: Equatable,C: Equatable,D: Equatable>(_ x: I<B>, _ y: I<C>, _ with: @escaping (A,B,C) -> D) -> I<D> {
        return flatMap { value1 in
            x.flatMap { value2 in
                y.map { with(value1, value2, $0) }
            }
        }
    }
    
    public subscript<R: Equatable>(keyPath: KeyPath<A,R>) -> I<R> {
        return map { $0[keyPath: keyPath] }
    }
}

public func lift<A>(_ f: @escaping (A,A) -> Bool) -> (A?,A?) -> Bool {
    return { l, r in
        switch (l,r) {
        case (nil,nil): return true
        case let (x?, y?): return f(x,y)
        default: return false
        }
    }
}

public func lift<A>(_ f: @escaping (A,A) -> Bool) -> ([A],[A]) -> Bool {
    return { l, r in
        l.count == r.count && !zip(l,r).lazy.map(f).contains(false)
    }
}

extension I where A: Equatable {
    convenience init() {
        self.init(eq: ==)
    }
    
    convenience init(value: A) {
        self.init(eq: ==, value: value)
    }
}

extension I: Equatable {
    public static func ==(lhs: I, rhs: I) -> Bool {
        return lhs === rhs
    }
}

