import Foundation

// todo shouldn't be public probably
public func appendOnly<A>(_ value: A, to: I<IList<A>>) {
    concatOnly(.cons(value, I(value: .empty)), to: to)
}

// concat to an immutable list
func concatOnly<A>(_ value: IList<A>, to: I<IList<A>>) {
    if case .empty = value { return }
    switch to.value! {
    case .empty:
        to.write(constant: value)
    case .cons(_, let tail):
        concatOnly(value, to: tail)
    }
}

func tail<A>(_ source: I<IList<A>>) -> I<IList<A>> {
    switch source.value! {
    case .cons(_, let t): return tail(t)
    case .empty: return source
    }
}

public indirect enum IList<A>: Equatable, CustomDebugStringConvertible where A: Equatable {

    case empty
    case cons(A, I<IList<A>>)

    public mutating func append(_ value: A) {
        switch self {
        case .empty: self = .cons(value, I(value: .empty))
        case .cons(_, let tail): tail.value.append(value)
        }
    }

    public mutating func concat(_ tail: IList<A>) {
        switch self {
        case .empty: self = tail
        case .cons(_, let t): t.value.concat(tail)
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

    public func reduce<B>(initial: B, combine: @escaping (A,B) -> B) -> I<B> where B: Equatable {
        return reduce(eq: ==, initial: initial, combine: combine)
    }

    public func reduce<B>(eq: @escaping (B,B) -> Bool, initial: B, combine: @escaping (A,B) -> B) -> I<B> {
        let result = I<B>(eq: eq)
        let node = reduceH(destination: result, initial: initial, combine: combine)
        result.strongReferences.add(node)
        return result
    }
    
    public func appendOnlyMap<B>(_ transform: @escaping (A) -> B) -> IList<B> {
        switch self {
        case .empty: return .empty
        case let .cons(x, xs):
            let result = xs.map { $0.appendOnlyMap(transform) }
            return .cons(transform(x), result)
        }
    }

    public var debugDescription: String {
        var result: [A] = []
        var x = self
        while case let .cons(value, remainder) = x {
            result.append(value)
            x = remainder.value
        }
        return "IList(\(result))"
    }
}

extension IList {
    public static func ==(l: IList<A>, r: IList<A>) -> Bool {
        switch (l, r) {
        case (.empty, .empty): return true
        default: return false
        }
    }
}

public enum ArrayChange<Element>: Equatable where Element: Equatable {
    case insert(Element, at: Int)
    case remove(at: Int)
    case replace(with: Element, at: Int)
    case move(at: Int, to: Int)

    public static func ==(lhs: ArrayChange<Element>, rhs: ArrayChange<Element>) -> Bool {
        switch (lhs, rhs) {
        case (.insert(let e1, let a1), .insert(let e2, let a2)):
            return e1 == e2 && a1 == a2
        case (.remove(let i1), .remove(let i2)):
            return i1 == i2
        case let (.replace(e1,i1), .replace(e2,i2)):
            return e1 == e2 && i1 == i2
        case let (.move(at: i1, to: i2), .move(at: i3, to: i4)):
            return i1 == i3 && i2 == i4
        default:
            return false
        }
    }
    
    public func map<B: Equatable>(_ transform: (Element) -> B) -> ArrayChange<B> {
        switch self {
        case let .insert(element, at: index):
            return .insert(transform(element), at: index)
        case .remove(at: let index):
            return .remove(at: index)
        case let .replace(with: element, at: index):
            return .replace(with: transform(element), at: index)
        case let .move(at: i1, to: i2):
            return .move(at: i1, to: i2)
        }
    }
}

extension Array where Element: Equatable {
    func applying(_ change: ArrayChange<Element>) -> [Element] {
        var copy = self
        copy.apply(change)
        return copy
    }
    public mutating func apply(_ change: ArrayChange<Element>) {
        switch change {
        case let .insert(e, at: i):
            self.insert(e, at: i)
        case .remove(at: let i):
            self.remove(at: i)
        case let .replace(with: e, at: i):
            self[i] = e
        case .move(let at, let to):
            if at == to { return }
            let value = self.remove(at: at)
            let offset = to > at ? -1 : 0
            self.insert(value, at: to + offset)
        }
    }
}

extension Array {
    func filteredIndex(for index: Int, _ isIncluded: (Element) -> Bool) -> Int {
        var skipped = 0
        for i in 0..<index {
            if !isIncluded(self[i]) {
                skipped += 1
            }
        }
        return index - skipped
    }
}

extension Array where Element: Equatable {
    public func filterChanges(oldCondition: (Element) -> Bool, newCondition: (Element) -> Bool) -> IList<ArrayChange<Element>> {
        // TODO: this is O(n^2) because of filteredIndex. Should be possible to make it O(n)
        var result: IList<ArrayChange<Element>> = .empty
        var offset = 0
        for (element, index) in zip(self, self.indices) {
            let old = oldCondition(element)
            let new = newCondition(element)
            let newIndex = filteredIndex(for: index, oldCondition)
            if old && !new {
                result.append(ArrayChange<Element>.remove(at: newIndex + offset))
                offset -= 1
            } else if !old && new {
                result.append(.insert(element, at: newIndex + offset))
                offset += 1
            }
        }
        return result
    }

    /// Returns the changes that need to be applied to get from self to self with `newSortOrder` applied.
    public func sortChanges(newSortOrder: (Element, Element) -> Bool) -> IList<ArrayChange<Element>> {
        var result: IList<ArrayChange<Element>> = .empty
        var inserts: [(Element, Int)] = []
        let newSorted = sorted(by: newSortOrder)
        for (element, oldIndex) in zip(self, self.indices).reversed() {
            // TODO calling index(of:) in each iteration is inefficient. we could use binary search here,
            // or provide an even more efficient implementation for elements that are hashable
            let newIndex = newSorted.index(of: element)!
            if oldIndex != newIndex {
                result.append(.remove(at: oldIndex))
                inserts.append((element, newIndex))
            }
        }
        let sortedInserts = inserts.sorted { $0.1 < $1.1 }
        for (element, newIndex) in sortedInserts {
            result.append(.insert(element, at: newIndex))
        }
        return result
    }
}

public final class ArrayWithHistory<A: Equatable>: Equatable {
    public let initial: [A]
    public let changes: I<IList<ArrayChange<A>>> // todo: this should be write-only
    public init(_ initial: [A]) {
        self.initial = initial
        self.changes = I(value: .empty)
    }
    init(_ initial: [A], changes: I<IList<ArrayChange<A>>>) {
        self.initial = initial
        self.changes = changes
    }

    public static func ==(lhs: ArrayWithHistory<A>, rhs: ArrayWithHistory<A>) -> Bool {
        return lhs === rhs
    }
}

extension ArrayWithHistory { // mutation. we could either track this with a phantom type, or only allow changes on creation... not sure yet.
    
    public func change(_ change: ArrayChange<A>) {
        appendOnly(change, to: changes)
    }
    
    // todo not so sure if this is a great idea! we should only expose append/change when creating an array anyway.
    public func append(_ value: A) {
        let index = self.unsafeLatestSnapshot.count
        self.change(.insert(value, at: index))
    }
    
    // todo I'm not sure if this is a good idea either... should only be used when mutating.
    public func index(of: A) -> Int? {
        return unsafeLatestSnapshot.index(of: of)
    }
    
    // todo not sure if this is the best idea
    public func remove(where condition: (A) -> Bool) {
        let reversed = self.unsafeLatestSnapshot.enumerated().reversed()
        for (index, item) in reversed {
            if condition(item) {
                self.change(.remove(at: index))
            }
        }
    }
    
    public func mutate(at index: Int, transform: (inout A) -> ()) {
        var value = unsafeLatestSnapshot[index]
        transform(&value)
        if unsafeLatestSnapshot[index] != value {
            self.change(.replace(with: value, at: index))
        }
    }
}

extension ArrayWithHistory {
    public func observe(current: ([A]) -> (), handleChange: @escaping (ArrayChange<A>) -> ()) -> Disposable {
        current(self.unsafeLatestSnapshot)
        let nEq: ((), ()) -> Bool = { _,_ in false }
        let (_, disposable) = tail(changes).read { c in
            c.reduce(eq: nEq, initial: (), combine: { change, _ in
                handleChange(change)
                return ()
            })
        }
        return disposable!
    }
}

extension ArrayWithHistory {
    var unsafeLatestSnapshot: [A] {
        var result: [A] = initial
        var x = changes
        while case let .cons(change, tail) = x.value! {
            result.apply(change)
            x = tail
        }
        return result
    }

    public var latest: I<[A]> {
        return changes.flatMap(eq: ==) { (changes: IList<ArrayChange<A>>) -> I<[A]> in
            return changes.reduce(eq: ==, initial: self.initial) { (change, r) in
                r.applying(change)
            }
        }
    }
    
    public var isEmpty: I<Bool> {
        return latest.map { $0.isEmpty }
    }
}

extension ArrayWithHistory {
    public func filter(_ condition: I<(A) -> Bool>) -> ArrayWithHistory<A> {
        // todo: the implementation of this is quite tricky, and I'm not sure if it's correct. it seems to work though. needs a solid test harness.
        var currentCondition: (A) -> Bool = condition.value
        let result = ArrayWithHistory(unsafeLatestSnapshot.filter(currentCondition))
        let resultChanges = result.changes
        var previous: Disposable? = nil // TODO this is unused, should it be?
        condition.read(target: resultChanges) { c in
            previous = nil
            let filterChanges = self.unsafeLatestSnapshot.filterChanges(oldCondition: currentCondition, newCondition: c)
            currentCondition = c
            concatOnly(filterChanges, to: resultChanges)
            return I(constant: ())
        }
        func filterH(target: AnyI, changesOut: I<IList<ArrayChange<A>>>, changesIn: IList<ArrayChange<A>>, latest: [A]) -> Node {
            switch changesIn {
            case .empty:
                return target
            case .cons(let change, let remainder):
                let newLatest = latest.applying(change)
                switch change {
                case let .insert(element, at: index) where currentCondition(element):
                    let newIndex = newLatest.filteredIndex(for: index, currentCondition)
                    appendOnly(.insert(element, at: newIndex), to: changesOut)
                case let .remove(at: index) where currentCondition(latest[index]):
                    let newIndex = latest.filteredIndex(for: index, currentCondition)
                    appendOnly(.remove(at: newIndex), to: changesOut)
                case let .replace(with: element, at: index) where currentCondition(latest[index]) || currentCondition(element):
                    let inPreviousResult = currentCondition(latest[index])
                    let inNewResult = currentCondition(element)
                    let newIndex = latest.filteredIndex(for: index, currentCondition)
                    if inPreviousResult && inNewResult {
                        // replace
                        appendOnly(.replace(with: element, at: newIndex), to: changesOut)
                    } else if inPreviousResult && !inNewResult {
                        // remove
                        appendOnly(.remove(at: newIndex), to: changesOut)
                    } else if !inPreviousResult && inNewResult {
                        // insert
                        appendOnly(.insert(element, at: newIndex), to: changesOut)
                    }
                    
                default:
                    ()
                }
                return remainder.read(target: target) { value in
                    return filterH(target: target, changesOut: changesOut, changesIn: value, latest: newLatest)
                }
                
            }
        }
        
        let currentValue = unsafeLatestSnapshot
        tail(self.changes).read(target: resultChanges) { (newChanges: IList<ArrayChange<A>>) in
            return filterH(target: resultChanges, changesOut: resultChanges, changesIn: newChanges, latest: currentValue)
        }
        return result
    }
    
    public func sort(by areInIncreasingOrder: I<(A, A) -> Bool>) -> ArrayWithHistory<A> {
        var currentSortOrder: (A, A) -> Bool = areInIncreasingOrder.value
        let result = ArrayWithHistory(unsafeLatestSnapshot.sorted(by: currentSortOrder))
        let resultChanges = result.changes
        areInIncreasingOrder.read(target: resultChanges) { order in
            let sortChanges = result.unsafeLatestSnapshot.sortChanges(newSortOrder: order)
            currentSortOrder = order
            concatOnly(sortChanges, to: resultChanges)
            return I(constant: ())
        }
        func sortH(target: AnyI, changesOut: I<IList<ArrayChange<A>>>, changesIn: IList<ArrayChange<A>>, latest: [A]) -> Node {
            switch changesIn {
            case .empty:
                return target
            case .cons(let change, let remainder):
                let newLatest = latest.applying(change)
                switch change {
                case let .insert(element, _):
                    // TODO this is inefficient, since we're sorting the original array each time to look up the index of the new element
                    let newIndex = newLatest.sorted(by: currentSortOrder).index(of: element)!
                    appendOnly(.insert(element, at: newIndex), to: changesOut)
                case let .remove(at: index):
                    let element = latest[index]
                    // TODO this is inefficient, since we're sorting the original array each time to look up the index of the new element
                    let newIndex = latest.sorted(by: currentSortOrder).index(of: element)!
                    appendOnly(.remove(at: newIndex), to: changesOut)
                case let .replace(with: element, at: index):
                    let previousElement = latest[index]
                    let previousElementSortedIndex = latest.sorted(by: currentSortOrder).index(of: previousElement)!
                    let newIndex = newLatest.sorted(by: currentSortOrder).index(of: element)!
                    if previousElementSortedIndex == newIndex {
                        appendOnly(.replace(with: element, at: newIndex), to: changesOut)
                    } else {
                        appendOnly(.move(at: previousElementSortedIndex, to: newIndex), to: changesOut)
                        appendOnly(.replace(with: element, at: newIndex), to: changesOut)
                    }
                case .move:
                    // ignore
                    ()
                }
                return remainder.read(target: target) { value in
                    return sortH(target: target, changesOut: changesOut, changesIn: value, latest: newLatest)
                }
            }
        }
        
        let currentValue = unsafeLatestSnapshot
        tail(self.changes).read(target: resultChanges) { (newChanges: IList<ArrayChange<A>>) in
            return sortH(target: resultChanges, changesOut: resultChanges, changesIn: newChanges, latest: currentValue)
        }
        return result
    }
    
    
    public func map<B>(_ transform: @escaping (A) -> B) -> ArrayWithHistory<B> {
        return ArrayWithHistory<B>(initial.map(transform), changes: changes.map { $0.appendOnlyMap { change in
            change.map(transform)
        }})
    }
}

public func flatten<A>(_ array: [I<A>]) -> ArrayWithHistory<A> {
    let initial = array.flatMap { $0.value }
    let result = ArrayWithHistory(initial)
    for (x, idx) in zip(array, array.indices) {
        x.read(target: result.changes) { change in
            appendOnly(.remove(at: idx), to: result.changes)
            appendOnly(.insert(change, at: idx), to: result.changes)
            return result.changes
        }
    }
    return result
}

