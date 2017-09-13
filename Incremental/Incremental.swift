import Foundation

struct Register<A> {
    typealias Token = Int
    private var items: [Token:A] = [:]
    private let freshNumber: () -> Int
    init() {
        var iterator = (0...).makeIterator()
        freshNumber = { iterator.next()! }
    }
    
    @discardableResult
    mutating func add(_ value: A) -> Token {
        let token = freshNumber()
        items[token] = value
        return token
    }
    
    mutating func remove(_ token: Token) {
        items[token] = nil
    }
    
    subscript(token: Token) -> A? {
        return items[token]
    }
    
    var values: AnySequence<A> {
        return AnySequence(items.values)
    }
    
    mutating func removeAll() {
        items = [:]
    }
    
    var keys: AnySequence<Token> {
        return AnySequence(items.keys)
    }
}

public final class Disposable {
    private let dispose: () -> ()
    init(dispose: @escaping () -> ()) {
        self.dispose = dispose
    }
    
    deinit {
        self.dispose()
    }
}

struct Height: CustomStringConvertible, Comparable {
    var value: Int
    
    init(_ value: Int = 0) {
        self.value = value
    }
    
    static let zero = Height(0)
    static let minusOne = Height(-1) // observers
    
    mutating func join(_ other: Height) {
        value = max(value, other.value)
    }
    
    func incremented() -> Height {
        return Height(value + 1)
    }
    
    var description: String {
        return "Height(\(value))"
    }
    
    static func <(lhs: Height, rhs: Height) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func ==(lhs: Height, rhs: Height) -> Bool {
        return lhs.value == rhs.value
    }
}


// This class is not thread-safe (and not meant to be).
final class Queue {
    static let shared = Queue()
    var edges: [(Edge, Height)] = []
    var processed: [Edge] = []
    var fired: [AnyI] = []
    var processing: Bool = false
    
    func enqueue(_ edges: [Edge]){
        self.edges.append(contentsOf: edges.map { ($0, $0.height) })
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

extension Array where Element == Height {
    var lub: Height {
        return reduce(into: .zero, { $0.join($1) })
    }
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



class Reader: Node, Edge {
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

protocol AnyI: class {
    var firedAlready: Bool { get set }
    var strongReferences: Register<Any> { get set }
}

public final class Var<A> {
    public let i: I<A>
    
    public init(_ value: A, eq: @escaping (A,A) -> Bool) {
        i = I(value: value, eq: eq)
    }
    
    public func set(_ newValue: A) {
        i.write(newValue)
    }
    
    public func change(_ by: (inout A) -> ()) {
        var copy = i.value!
        by(&copy)
        i.write(copy)
    }
}

public extension Var where A: Equatable {
    public convenience init(_ value: A) {
        self.init(value, eq: ==)
    }
}


extension I where A: Equatable {
    convenience init(value: A) {
        self.init(value: value, eq: ==)
    }
}

public final class I<A>: AnyI, Node {
    fileprivate var value: A!
    var observers = Register<Observer>()
    var readers: Register<Reader> = Register()
    var height: Height {
        return readers.values.map { $0.height }.lub.incremented()
    }
    var firedAlready: Bool = false
    var strongReferences: Register<Any> = Register()
    var eq: (A,A) -> Bool
    private let constant: Bool
    
    init(value: A, eq: @escaping (A, A) -> Bool) {
        self.value = value
        self.eq = eq
        self.constant = false
    }
    
    fileprivate init(eq: @escaping (A,A) -> Bool) {
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
    
    /// Returns `self`
    @discardableResult
    fileprivate func write(_ value: A) -> I<A> {
        assert(!constant)
        if let existing = self.value, eq(existing, value) { return self }
        
        self.value = value
        guard !firedAlready else { return self }
        firedAlready = true
        Queue.shared.enqueue(Array(readers.values))
        Queue.shared.enqueue(Array(observers.values))
        Queue.shared.fired(self)
        Queue.shared.process()
        return self
    }
    
    func read(_ read: @escaping (A) -> Node) -> (Reader, Disposable) {
        let reader = Reader(read: {
            read(self.value)
        })
        if constant {
            return (reader, Disposable { })
        }
        let token = readers.add(reader)
        return (reader, Disposable {
            self.readers[token]?.invalidated = true
            self.readers.remove(token)
        })
    }
    
    @discardableResult
    func read(target: AnyI, _ read: @escaping (A) -> Node) -> Reader {
        let (reader, disposable) = self.read(read)
        target.strongReferences.add(disposable)
        return reader
    }
    
    func connect<B>(result: I<B>, _ transform: @escaping (A) -> B) {
        read(target: result) { value in
            result.write(transform(value))
        }
    }
    
    public func map<B: Equatable>(_ transform: @escaping (A) -> B) -> I<B> {
        let result = I<B>(eq: ==)
        connect(result: result, transform)
        return result
    }
    
    // convenience for optionals
    public func map<B: Equatable>(_ transform: @escaping (A) -> B?) -> I<B?> {
        let result = I<B?>(eq: ==)
        connect(result: result, transform)
        return result
    }
    
    // convenience for arrays
    public func map<B: Equatable>(_ transform: @escaping (A) -> [B]) -> I<[B]> {
        let result = I<[B]>(eq: ==)
        connect(result: result, transform)
        return result
    }
    
    // convenience for other types
    public func map<B>(eq: @escaping (B,B) -> Bool, _ transform: @escaping (A) -> B) -> I<B> {
        let result = I<B>(eq: eq)
        connect(result: result, transform)
        return result
    }
    
    //    // convenience for other types
    //    func map<B>(eq: @escaping (B,B) -> Bool, _ transform: @escaping (A) -> B?) -> I<B?> {
    //        let result = I<B?>(eq: {
    //            switch ($0, $1) {
    //            case (nil,nil): return true
    //            case let (x?, y?): return eq(x,y)
    //            default: return false
    //            }
    //        })
    //        connect(result: result, transform)
    //        return result
    //    }
    
    
    public func flatMap<B: Equatable>(_ transform: @escaping (A) -> I<B>) -> I<B> {
        let result = I<B>(eq: ==)
        var previous: Disposable?
        // todo: we might be able to avoid this closure by having a custom "flatMap" reader
        read(target: result) { value in
            previous = nil
            let (reader, disposable) = transform(value).read { value2 in
                result.write(value2)
            }
            let token = result.strongReferences.add(disposable)
            previous = Disposable { result.strongReferences.remove(token) }
            return reader
        }
        return result
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
    
    
    func mutate(_ transform: (inout A) -> ()) {
        var newValue = value!
        transform(&newValue)
        write(newValue)
    }
}

public func if_<A: Equatable>(_ condition: I<Bool>, then l: I<A>, else r: I<A>) -> I<A> {
    return condition.flatMap { $0 ? l : r }
}

public func &&(l: I<Bool>, r: I<Bool>) -> I<Bool> {
    return l.zip2(r, { $0 && $1 })
}

public func ||(l: I<Bool>, r: I<Bool>) -> I<Bool> {
    return l.zip2(r, { $0 || $1 })
}

public prefix func !(l: I<Bool>) -> I<Bool> {
    return l.map { !$0 }
}

public func ==<A>(l: I<A>, r: I<A>) -> I<Bool> where A: Equatable {
    return l.zip2(r, ==)
}

// The code below isn't really ready to be public yet... need to think more about this.
enum IList<A>: Equatable where A: Equatable {
    case empty
    case cons(A, I<IList<A>>)
    
    mutating func append(_ value: A) {
        switch self {
        case .empty: self = .cons(value, I(value: .empty))
        case .cons(_, let tail): tail.value.append(value)
        }
    }
    
    func reduceH<B>(destination: I<B>, initial: B, combine: @escaping (A,B) -> B) -> Node {
        switch self {
        case .empty:
            destination.write(initial)
            return destination
        case let .cons(value, tail):
            let intermediate = combine(value, initial)
            return tail.read(target: destination) { newTail in
                newTail.reduceH(destination: destination, initial: intermediate, combine: combine)
            }
        }
    }
}

extension IList {
    static func ==(l: IList<A>, r: IList<A>) -> Bool {
        switch (l, r) {
        case (.empty, .empty): return true
        default: return false
        }
    }
}
