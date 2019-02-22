import Foundation

public class Token: CustomStringConvertible {
    public enum Kind {
        case EndOfFile
        case IntegerLiteral(value: Int)
    }

    public let kind: Kind
    public let text: String
    public let location: Location

    public var description: String {
        return "Token(\(kind), \(self.text), \(self.location))"
    }

    public var isEOF: Bool {
        if case .EndOfFile = self.kind {
            return true
        }
        return false
    }

    public var integerLiteralValue: Int? {
        if case .IntegerLiteral(let value) = self.kind {
            return value
        }
        return nil
    }

    public init(kind: Kind, text: String, location: Location) {
        self.kind = kind
        self.text = text
        self.location = location
    }
}
