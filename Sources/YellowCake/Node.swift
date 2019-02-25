public class VariableSymbol {
    public let name: String
    public let location: Location

    public init(name: String, location: Location) {
        self.name = name
        self.location = location
    }
}

public class Scope {
    public weak var parent: Scope?

    private var symbols: [String: VariableSymbol]

    public init(parent: Scope?) {
        self.parent = parent
        self.symbols = [:]
    }

    public func findSymbol(name: String, recursive: Bool) -> VariableSymbol? {
        if let symbol = self.symbols[name] {
            return symbol
        }

        if recursive {
            return self.parent?.findSymbol(name: name, recursive: true)
        }

        return nil
    }

    public func register(symbol: VariableSymbol) -> Bool {
        if let _ = self.symbols[symbol.name] {
            return false
        }

        self.symbols[symbol.name] = symbol
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
