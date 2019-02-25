public class Statement: CustomStringConvertible {
    public enum Kind {
        case Compound([Statement])
        case Return(Expression)
        case Expression(Expression)
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

public class Expression: CustomStringConvertible {
    public enum Kind {
        case Integer(Int)
        case Add(Expression, Expression)
        case Subtract(Expression, Expression)
        case Multiply(Expression, Expression)
        case Divide(Expression, Expression)
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
