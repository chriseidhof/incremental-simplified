internal extension Equatable {
    /// Used to form an identity key path.
    ///
    /// - SeeAlso: https://forums.swift.org/t/some-small-keypath-extensions-identity-and-tuple-components/13729
    var keyPathSelf: Self {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
