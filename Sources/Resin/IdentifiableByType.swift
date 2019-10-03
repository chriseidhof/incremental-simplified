/// A value-type that can be used as a key when mapping types to values in a
/// dictionary.
internal struct TypeIdentifier: Hashable, RawRepresentable, CustomStringConvertible {
    public let rawValue: ObjectIdentifier
    #if DEBUG
    public let name: String
    #endif

    public init(value: Any) {
        self.init(type: type(of: value))
    }

    public init(type: Any.Type) {
        self.rawValue = ObjectIdentifier(Swift.type(of: type))
        #if DEBUG
        self.name = Mirror(reflecting: type).description
        #endif
    }

    public init?(rawValue: ObjectIdentifier) {
        self.rawValue = rawValue
        #if DEBUG
        self.name = rawValue.debugDescription
        #endif
    }

    public var description: String {
        #if DEBUG
        return "TypeIdentifier(\(name)-\(rawValue.debugDescription))"
        #else
        return "TypeIdentifier(\(rawValue.debugDescription))"
        #endif
    }
}
