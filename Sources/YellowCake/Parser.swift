import Foundation

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

    public func parse() throws -> Node {
        let token = try self.stream.consume()
        let loc = token.location

        if let value = token.integerLiteralValue {
            return Node(kind: .IntegerExpr(value: value), location: loc)
        }

        throw SyntaxError.UnexpectedToken(token: token)
    }
}
