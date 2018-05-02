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
    public init(dispose: @escaping () -> ()) {
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
    
    static func +(lhs: Height, rhs: Height) -> Height {
        return Height(lhs.value + rhs.value)
    }
}

extension Sequence where Element == Height {
    var leastUpperBound: Height {
        return reduce(into: .zero, { $0.join($1) })
    }
}
