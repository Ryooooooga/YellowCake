import Foundation

public enum SemanticError: Error {
    case MultipleDeclaration(VariableSymbol)
}

private func semanticAnalyze(expression: Expression, scope: Scope) throws {
    switch expression.kind {
        case .Integer(_):
            break

        case let .Add(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

        case let .Subtract(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

        case let .Multiply(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)

        case let .Divide(left, right):
            try semanticAnalyze(expression: left, scope: scope)
            try semanticAnalyze(expression: right, scope: scope)
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

    case let .Return(expr):
        try semanticAnalyze(expression: expr, scope: scope)

    case let .Let(symbol, initializer):
        try semanticAnalyze(expression: initializer, scope: scope)

        guard scope.register(symbol: symbol) else {
            throw SemanticError.MultipleDeclaration(symbol)
        }

    case let .Expression(expr):
        try semanticAnalyze(expression: expr, scope: scope)
    }
}

private func semanticAnalyze(declaration: Declaration, scope: Scope) throws {
    switch declaration.kind {
    case let .Function(attr):
        attr.scope = Scope(parent: scope)

        try semanticAnalyze(statement: attr.body, scope: attr.scope!)
    }
}

public func semanticAnalyze(node: Declaration) throws {
    let globalScope = Scope(parent: nil)

    try semanticAnalyze(declaration: node, scope: globalScope)
}
