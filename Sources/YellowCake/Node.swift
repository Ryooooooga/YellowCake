import Foundation

public class Type {
    public enum Kind {
        case Int64
        case Function
    }

    public let kind: Kind

    public var isInt64: Bool {
        if case .Int64 = self.kind {
            return true
        }
        return false
    }

    public var isFunction: Bool {
        if case .Function = self.kind {
            return true
        }
        return false
    }

    public static let int64: Type = Type(kind: .Int64)

    public init(kind: Kind) {
        self.kind = kind
    }
}

public class VariableSymbol: Hashable {
    public let name: String
    public let location: Location
    public var type: Type?

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    public init(name: String, location: Location) {
        self.name = name
        self.location = location
        self.type =  nil
    }

    public static func == (lhs: VariableSymbol, rhs: VariableSymbol) -> Bool {
        return lhs === rhs
    }
}

public class Scope {
    public weak var parent: Scope?

    private var children: [Scope]
    private var symbols: [VariableSymbol]

    public var wholeSymbols: [VariableSymbol] {
        return self.children.reduce(into: self.symbols) {
            $0 += $1.wholeSymbols
        }
    }

    public init(parent: Scope?) {
        self.parent = parent
        self.children = []
        self.symbols = []

        if let parent = self.parent {
            parent.children.append(self)
        }
    }

    public func findSymbol(name: String, recursive: Bool) -> VariableSymbol? {
        if let symbol = self.symbols.first(where: { $0.name == name }) {
            return symbol
        }

        if recursive {
            return self.parent?.findSymbol(name: name, recursive: true)
        }

        return nil
    }

    public func register(symbol: VariableSymbol) -> Bool {
        if let _ = self.findSymbol(name: symbol.name, recursive: false) {
            return false
        }

        self.symbols.append(symbol)
        return true
    }
}

public class FunctionAttribute {
    public let symbol: VariableSymbol
    public let body: Statement

    internal var scope: Scope?

    public init(symbol: VariableSymbol, body: Statement) {
        self.symbol = symbol
        self.body = body
        self.scope = nil
    }
}

public class CompoundStatementAttribute {
    public let statements: [Statement]

    internal var scope: Scope?

    public init(statements: [Statement]) {
        self.statements = statements
        self.scope = nil
    }
}

public class Declaration: CustomStringConvertible {
    public enum Kind {
        case Function(FunctionAttribute)
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

public class Statement: CustomStringConvertible {
    public enum Kind {
        case Compound(CompoundStatementAttribute)
        case If(Expression, Statement, Statement?)
        case Return(Expression)
        case Let(VariableSymbol, Expression)
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

public class IdentifierExpressionAttribute {
    public let name: String

    internal var symbol: VariableSymbol?

    public init(name: String) {
        self.name = name
        self.symbol = nil
    }
}

public class Expression: CustomStringConvertible {
    public enum Kind {
        case Integer(Int)
        case Identifier(IdentifierExpressionAttribute)
        case Add(Expression, Expression)
        case Subtract(Expression, Expression)
        case Multiply(Expression, Expression)
        case Divide(Expression, Expression)
    }

    public let kind: Kind
    public let location: Location

    internal var type: Type?

    public var description: String {
        return "(\(self.kind) at: \(self.location))"
    }

    public init(kind: Kind, location: Location) {
        self.kind = kind
        self.location = location
    }
}
