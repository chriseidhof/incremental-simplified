import Foundation

struct Register<A> {
    typealias Token = Int
    private var items: [Token:A] = [:]
    private let freshNumber: () -> Int
    init() {
        var iterator = (0...).makeIterator()
        freshNumber = { iterator.next()! }
    }
    
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

final class Disposable {
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

protocol AnyI: class {
    var firedAlready: Bool { get set }
}

final class Queue {
    static let shared = Queue()
    var edges: [Edge] = []
    var processed: [Edge] = []
    var fired: [AnyI] = []
    var processing: Bool = false
    
    func enqueue(_ edges: [Edge]){
        self.edges.append(contentsOf: edges)
        self.edges.sort { $0.height < $1.height }
    }
    
    func fired(_ source: AnyI) {
        fired.append(source)
    }
    
    func process() {
        guard !processing else { return }
        processing = true
        while let edge = edges.popLast() {
            guard !processed.contains(where: { $0 === edge }) else {
                continue
            }
            processed.append(edge)
            edge.fire()
        }
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
    let read: () -> [Node]
    var height: Height {
        return children.map { $0.height }.lub.incremented()
    }
    var children: [Node]
    var invalidated: Bool = false
    init(read: @escaping () -> [Node]) {
        self.read = read
        children = read()
    }
    
    func fire() {
        if invalidated {
            return
        }
        children = read()
    }
}

final class I<A>: AnyI, Node {
    fileprivate var value: A!
    var observers = Register<Observer>()
    var readers: Register<Reader> = Register()
    var height: Height {
        return readers.values.map { $0.height }.lub.incremented()
    }
    var firedAlready: Bool = false
    fileprivate var strongReferences: Register<Any> = Register()
    
    init(value: A) {
        self.value = value
    }
    fileprivate init() {
    }
    
    func observe(_ observer: @escaping (A) -> ()) -> Disposable {
        let token = observers.add(Observer {
            observer(self.value)
        })
        return Disposable { /* should this be weak/unowned*/
            self.observers.remove(token)
        }
    }
    
    fileprivate func write(_ value: A) {
        self.value = value
        guard !firedAlready else { return }
        firedAlready = true
        Queue.shared.enqueue(Array(readers.values))
        Queue.shared.enqueue(Array(observers.values))
        Queue.shared.fired(self)
        Queue.shared.process()
    }
    
    func read(_ read: @escaping (A) -> [Node]) -> (Reader, Disposable) {
        var reader: Reader!
        reader = Reader(read: {
            read(self.value)
        })
        let token = readers.add(reader)
        return (reader, Disposable {
            self.readers[token]?.invalidated = true
            self.readers.remove(token)
        })
    }
    
    func map<B>(_ transform: @escaping (A) -> B) -> I<B> {
        let result = I<B>()
        let (_, disposable) = read { value in
            let newValue = transform(value)
            result.write(newValue)
            return [result]
        }
        result.strongReferences.add(disposable)
        return result
    }
    
    func zip<B,C>(_ other: I<B>, _ with: @escaping (A,B) -> C) -> I<C> {
        let result = I<C>()
        var previous: (Reader, Register<Any>.Token)?
        let (_, disposable) = read { value1 in
            if let p = previous {
                p.0.invalidated = true
                result.strongReferences.remove(p.1)
            }
            let (reader, disposable2) = other.read { value2 in
                result.write(with(value1, value2))
                return [result]
            }
            previous = (reader, result.strongReferences.add(disposable2))
            return [reader]
        }
        _ = result.strongReferences.add(disposable)
        return result
    }
    
    func flatMap<B>(_ transform: @escaping (A) -> I<B>) -> I<B> {
        var result = I<B>()
        var previous: (Reader, Register<Any>.Token)?
        let (_, disposable) = read { value in
            if let p = previous {
                p.0.invalidated = true
                result.strongReferences.remove(p.1)
            }
            let (reader, disposable2) = transform(value).read { value2 in
                result.write(value2)
                return [result]
            }
            previous = (reader, result.strongReferences.add(disposable2))
            return [reader]
        }
        _ = result.strongReferences.add(disposable)
        return result
    }
    
    func mutate(_ transform: (inout A) -> ()) {
        var newValue = value!
        transform(&newValue)
        write(newValue)
    }
}

enum IList<A> {
    case empty
    case cons(A, I<IList<A>>)
    
    mutating func append(_ value: A) {
        switch self {
        case .empty: self = .cons(value, I(value: .empty))
        case .cons(_, let tail): tail.value.append(value)
        }
    }
    
    func reduceH<B>(destination: I<B>, initial: B, combine: @escaping (A,B) -> B) -> [Node] {
        switch self {
        case .empty:
            destination.write(initial)
            return [destination]
        case let .cons(value, tail):
            let intermediate = combine(value, initial)
            let (reader, disposable) = tail.read { newTail in
                return newTail.reduceH(destination: destination, initial: intermediate, combine: combine)
            }
            tail.strongReferences.add(disposable)
            return [reader]
        }
    }
}

let x = I<Int>(value: 1)
let y = x.map { $0 + 1 }
let z = x.zip(y, +)
let test: I<Int> = z.flatMap { value in
    if value > 4 {
        return x.map { $0 * 10 }
    } else {
        return x
    }
}
let disposable = z.zip(test, { ($0,$1) }).observe { print($0) }
x.write(5)


