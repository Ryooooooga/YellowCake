import Foundation

private enum Precedence: Int {
    case Min
    case Additive
    case Multiplicative
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

        throw SyntaxError.UnexpectedToken(token: token)
    }

    // PrefixExpr:
    //  IntegerExpr
    private func parsePrefixExpr() throws -> Expression {
        let token = try self.stream.consume()
        let loc = token.location

        switch token.kind {
            // IntegerExpr
        case let .IntegerLiteral(value):
            return Expression(kind: .IntegerExpr(value), location: loc)

        default:
            throw SyntaxError.UnexpectedToken(token: token)
        }
    }

    // AddExpr:
    //  '+' Expr
    private func parseAddExpr(left: Expression) throws -> Expression {
        // '+'
        let token = try self.expectToken { $0.isPunctuator("+") }

        // Expr
        let right = try self.parseExpr(level: .Multiplicative)

        return Expression(kind: .Add(left, right), location: token.location)
    }

    // InfixExpr:
    //  AddExpr
    //  <empty>
    private func parseInfixExpr(left: Expression, level: Precedence) throws -> Expression {
        var expr = left

        while true {
            let prefixToken = try self.stream.peek()

            if prefixToken.isPunctuator("+") && level <= Precedence.Additive {
                expr = try parseAddExpr(left: expr)
            } else {
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

    // Program:
    //  Expr EOF
    public func parse() throws -> Expression {
        // Expr
        let expr = try self.parseExpr(level: .Min)

        // EOF
        _ = try self.expectToken { $0.isEOF }

        return expr
    }
}
