import Foundation

public enum SemanticError: Error {
    case MultipleDeclaration(VariableSymbol)
    case UndeclaredIdentifier(String, Location)
    case InvalidType(Location)
}

private func semanticAnalyze(expression: Expression, scope: Scope) throws {
    switch expression.kind {
        case .Integer(_):
            expression.type = Type.int64

        case let .Identifier(attr):
            guard let symbol = scope.findSymbol(name: attr.name, recursive: true) else {
                throw SemanticError.UndeclaredIdentifier(attr.name, expression.location)
            }

            attr.symbol = symbol
            expression.type = attr.symbol!.type!

        case let .Add(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

            guard left.type?.isInt64 ?? false && right.type?.isInt64 ?? false else {
                throw SemanticError.InvalidType(expression.location)
            }

            expression.type = left.type!

        case let .Subtract(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

            guard left.type?.isInt64 ?? false && right.type?.isInt64 ?? false else {
                throw SemanticError.InvalidType(expression.location)
            }

            expression.type = left.type!

        case let .Multiply(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

            guard left.type?.isInt64 ?? false && right.type?.isInt64 ?? false else {
                throw SemanticError.InvalidType(expression.location)
            }

            expression.type = left.type!

        case let .Divide(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

            guard left.type?.isInt64 ?? false && right.type?.isInt64 ?? false else {
                throw SemanticError.InvalidType(expression.location)
            }

            expression.type = left.type!
    }
}

private func semanticAnalyze(statement: Statement, scope: Scope) throws {
    switch statement.kind {
    case let .Compound(attr):
        attr.scope = Scope(parent: scope)

        for stmt in attr.statements {
            try semanticAnalyze(statement: stmt, scope: attr.scope!)
        }

    case let .If(cond, then, else_):
        try semanticAnalyze(expression: cond, scope: scope)
        try semanticAnalyze(statement: then, scope: scope)

        if let else_ = else_ {
            try semanticAnalyze(statement: else_, scope: scope)
        }

        guard cond.type?.isInt64 ?? false else {
            throw SemanticError.InvalidType(cond.location)
        }

    case let .Return(expr):
        try semanticAnalyze(expression: expr, scope: scope)

        guard expr.type?.isInt64 ?? false else {
            throw SemanticError.InvalidType(expr.location)
        }

    case let .Let(symbol, initializer):
        try semanticAnalyze(expression: initializer, scope: scope)

        guard scope.register(symbol: symbol) else {
            throw SemanticError.MultipleDeclaration(symbol)
        }

        symbol.type = Type.int64

        guard initializer.type?.isInt64 ?? false else {
            throw SemanticError.InvalidType(initializer.location)
        }

    case let .Expression(expr):
        try semanticAnalyze(expression: expr, scope: scope)
    }
}

private func semanticAnalyze(declaration: Declaration, scope: Scope) throws {
    switch declaration.kind {
    case let .Function(attr):
        attr.scope = Scope(parent: scope)
        attr.symbol.type = Type(kind: .Function)

        try semanticAnalyze(statement: attr.body, scope: attr.scope!)
    }
}

public func semanticAnalyze(node: Declaration) throws {
    let globalScope = Scope(parent: nil)

    try semanticAnalyze(declaration: node, scope: globalScope)
}
