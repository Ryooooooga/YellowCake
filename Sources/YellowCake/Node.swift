public class Node: CustomStringConvertible {
    public enum Kind {
        case IntegerExpr(value: Int)
    }

    public let kind: Kind
    public let location: Location

    public var description: String {
        return "(\(self.kind) at: \(self.location))"
    }

    public init(kind: Kind, location: Location) {
        self.kind = kind
        self.location = location
    }
}
