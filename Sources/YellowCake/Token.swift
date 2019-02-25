import Foundation

public class Token: CustomStringConvertible {
    public enum Kind {
        case EndOfFile
        case IntegerLiteral(Int)
        case Identifier(String)
        case Symbol(String)
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

    public var isIdentifier: Bool {
        if case .Identifier(_) = self.kind {
            return true
        }
        return false
    }

    public var integerLiteralValue: Int? {
        if case let .IntegerLiteral(value) = self.kind {
            return value
        }
        return nil
    }

    public var identifierName: String? {
        if case let .Identifier(name) = self.kind {
            return name
        }
        return nil
    }

    public init(kind: Kind, text: String, location: Location) {
        self.kind = kind
        self.text = text
        self.location = location
    }

    public func isSymbol(_ text: String) -> Bool {
        if case let .Symbol(punct) = self.kind {
            return punct == text
        }
        return false
    }
}
