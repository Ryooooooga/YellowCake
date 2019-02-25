import Foundation

public class VariableSymbol: Hashable {
    public let name: String
    public let location: Location

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    public init(name: String, location: Location) {
        self.name = name
        self.location = location
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
