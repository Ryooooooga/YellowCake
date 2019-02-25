import Foundation

private enum Precedence: Int {
    case Min
    case Additive
    case Multiplicative
    case Prefix
}

private extension Precedence {
    static func == (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    static func != (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue != rhs.rawValue
    }

    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    static func <= (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }

    static func > (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }

    static func >= (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
}

public class Parser {
    private let stream: TokenStream

    public var filename: String {
        return self.stream.filename
    }

    public var source: String {
        return self.stream.source
    }

    public init(lexer: Lexer) {
        self.stream = TokenStream(lexer: lexer)
    }

    private func expectToken(_ pred: (Token) -> Bool) throws -> Token {
        let token = try self.stream.consume()

        if pred(token) {
            return token
        }

        throw SyntaxError.UnexpectedToken(token: token, filename: self.filename)
    }

    // PrefixExpr:
    //  ParenExpr
    //  IntegerExpr
    private func parsePrefixExpr() throws -> Expression {
        let token = try self.stream.consume()
        let loc = token.location

        switch token.kind {
            // ParenExpr
        case .Symbol("("):
            let expr = try self.parseExpr(level: .Min)
            _ = try self.expectToken { $0.isSymbol(")") }

            return expr

            // IntegerExpr
        case let .IntegerLiteral(value):
            return Expression(kind: .Integer(value), location: loc)

        default:
            throw SyntaxError.UnexpectedToken(token: token, filename: self.filename)
        }
    }

    // AddExpr:
    //  '+' Expr
    private func parseAddExpr(left: Expression) throws -> Expression {
        // '+'
        let token = try self.expectToken { $0.isSymbol("+") }

        // Expr
        let right = try self.parseExpr(level: .Multiplicative)

        return Expression(kind: .Add(left, right), location: token.location)
    }

    // SubtractExpr:
    //  '-' Expr
    private func parseSubtractExpr(left: Expression) throws -> Expression {
        // '-'
        let token = try self.expectToken { $0.isSymbol("-") }

        // Expr
        let right = try self.parseExpr(level: .Multiplicative)

        return Expression(kind: .Subtract(left, right), location: token.location)
    }

    // MultiplyExpr:
    //  '*' Expr
    private func parseMultiplyExpr(left: Expression) throws -> Expression {
        // '*'
        let token = try self.expectToken { $0.isSymbol("*") }

        // Expr
        let right = try self.parseExpr(level: .Prefix)

        return Expression(kind: .Multiply(left, right), location: token.location)
    }

    // DivideExpr:
    //  '/' Expr
    private func parseDivideExpr(left: Expression) throws -> Expression {
        // '/'
        let token = try self.expectToken { $0.isSymbol("/") }

        // Expr
        let right = try self.parseExpr(level: .Prefix)

        return Expression(kind: .Divide(left, right), location: token.location)
    }

    // InfixExpr:
    //  AddExpr
    //  SubtractExpr
    //  MultiplyExpr
    //  DivideExpr
    //  <empty>
    private func parseInfixExpr(left: Expression, level: Precedence) throws -> Expression {
        var expr = left

        while true {
            let token = try self.stream.peek()

            switch token.kind {
            case .Symbol("+") where level <= Precedence.Additive:
                expr = try self.parseAddExpr(left: expr)
            case .Symbol("-") where level <= Precedence.Additive:
                expr = try self.parseSubtractExpr(left: expr)
            case .Symbol("*") where level <= Precedence.Multiplicative:
                expr = try self.parseMultiplyExpr(left: expr)
            case .Symbol("/") where level <= Precedence.Multiplicative:
                expr = try self.parseDivideExpr(left: expr)
            default:
                return expr
            }
        }
    }

    // Expr:
    //  PrefixExpr InfixExpr
    private func parseExpr(level: Precedence) throws -> Expression {
        // PrimaryExpr
        let expr = try self.parsePrefixExpr()

        // InfixExpr
        return try parseInfixExpr(left: expr, level: level)
    }

    // CompoundStmt:
    //  '{' {Stmt} '}'
    private func parseCompoundStmt() throws -> Statement {
        // '{'
        let token = try self.expectToken { $0.isSymbol("{") }

        // {Stmt}
        var stmts = [Statement]()

        while !(try self.stream.peek()).isSymbol("}") {
            stmts.append(try self.parseStmt())
        }

        // '}'
        _ = try self.expectToken { $0.isSymbol("}") }

        return Statement(kind: .Compound(CompoundStatementAttribute(statements: stmts)), location: token.location)
    }

    // IfStmt:
    //  'if' Expr CompoundStmt 'else' CompoundStmt
    //  'if' Expr CompoundStmt
    private func parseIfStmt() throws -> Statement {
        // 'if'
        let token = try self.expectToken { $0.isSymbol("if") }

        // Expr
        let condition = try self.parseExpr(level: .Min)

        // CompoundStmt
        let then = try self.parseCompoundStmt()

        // ['else']
        guard let _ = try self.stream.consume(if: { $0.isSymbol("else") }) else {
            return Statement(kind: .If(condition, then, nil), location: token.location)
        }

        // CompoundStmt
        let else_ = try self.parseCompoundStmt()

        return Statement(kind: .If(condition, then, else_), location: token.location)
    }

    // ReturnStmt:
    //  'return' Expr ';'
    private func parseReturnStmt() throws -> Statement {
        // 'return'
        let token = try self.expectToken { $0.isSymbol("return") }

        // Expr
        let expr = try self.parseExpr(level: .Min)

        // ';'
        _ = try self.expectToken { $0.isSymbol(";") }

        return Statement(kind: .Return(expr), location: token.location)
    }

    // LetStmt:
    //  'let' Identifier '=' Expr ';'
    private func parseLetStmt() throws -> Statement {
        // 'let'
        let token = try self.expectToken { $0.isSymbol("let") }

        // Identifier
        let name = try self.expectToken { $0.isIdentifier }

        // '='
        _ = try self.expectToken { $0.isSymbol("=") }

        // Expr
        let initializer = try self.parseExpr(level: .Min)

        // ';'
        _ = try self.expectToken { $0.isSymbol(";") }

        let symbol = VariableSymbol(name: name.identifierName!, location: name.location)

        return Statement(kind: .Let(symbol, initializer), location: token.location)
    }

    // ExprStmt:
    //  Expr ';'
    private func parseExprStmt() throws -> Statement {
        // Expr
        let expr = try self.parseExpr(level: .Min)

        // ';'
        let token = try self.expectToken { $0.isSymbol(";") }

        return Statement(kind: .Expression(expr), location: token.location)
    }

    // Stmt:
    //  CompoundStmt
    //  IfStmt
    //  ReturnStmt
    //  LetStmt
    //  ExprStmt
    private func parseStmt() throws -> Statement {
        let token = try self.stream.peek()

        switch token.kind {
        case .Symbol("{"):
            return try self.parseCompoundStmt()

        case .Symbol("if"):
            return try self.parseIfStmt()

        case .Symbol("return"):
            return try self.parseReturnStmt()

        case .Symbol("let"):
            return try self.parseLetStmt()

        default:
            return try self.parseExprStmt()
        }
    }

    // Program:
    //  Stmt EOF
    public func parse() throws -> Declaration {
        // Stmt
        let body = try self.parseStmt()

        // EOF
        let token = try self.expectToken { $0.isEOF }

        let symbol = VariableSymbol(name: "anonymous", location: token.location)
        let attr = FunctionAttribute(symbol: symbol, body: body)

        return Declaration(kind: .Function(attr), location: token.location)
    }
}
