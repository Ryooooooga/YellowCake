public class TokenStream {
    private let lexer: Lexer
    private var lookahead: [Token]

    public var filename: String {
        return self.lexer.filename
    }

    public var source: String {
        return self.lexer.source
    }

    public init(lexer: Lexer) {
        self.lexer = lexer
        self.lookahead = []
    }

    private func fill(_ n: Int) throws {
        while self.lookahead.count < n {
            self.lookahead.append(try self.lexer.read())
        }
    }

    public func peek(pos: Int = 0) throws -> Token {
        try self.fill(pos + 1)
        return self.lookahead[pos]
    }

    public func consume() throws -> Token {
        let token = try self.peek()
        self.lookahead.remove(at: 0)

        return token
    }

    public func consume(if pred: (Token) -> Bool) throws -> Token? {
        if pred(try self.peek()) {
            return try self.consume()
        }
        return nil
    }
}
