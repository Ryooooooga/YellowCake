import Foundation

public class Token: CustomStringConvertible {
    public enum Kind {
        case IntegerLiteral(value: Int)
    }

    public let kind: Kind
    public let text: String
    public let location: Location

    public var description: String {
        return "Token(\(kind), \(self.text), \(self.location))"
    }

    public init(kind: Kind, text: String, location: Location) {
        self.kind = kind
        self.text = text
        self.location = location
    }
}
