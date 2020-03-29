import Foundation

public struct Station: Equatable {
    var lines: [String]

    var name: String

    var zones: [Int]

    public init(name: String, lines: [String], zones: [Int]) {
        self.name = name
        self.lines = lines
        self.zones = zones
    }
}

extension Station: Hashable {
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}
