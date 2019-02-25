import Foundation

private extension Unicode.Scalar {
    var isDigit: Bool {
        return "0" <= self && self <= "9"
    }

    var isIdentifierStart: Bool {
        return ("A" <= self && self <= "Z") || ("a" <= self && self <= "z") || (self == "_")
    }

    var isIdentifierContinuation: Bool {
        return self.isIdentifierStart || self.isDigit
    }
}

public class Lexer {
    public let filename: String
    public let source: String

    private var index: String.UnicodeScalarView.Index
    private var loc: Location

    private var restChars: Substring.UnicodeScalarView {
        return self.source.unicodeScalars[self.index ..< self.source.unicodeScalars.endIndex]
    }

    private static let keywords: [String] = [
        "if", "else",
        "return",
    ]

    private static let punctuators: [String] = [
        "+", "-","*","/",
        "(",")", "{", "}",
        ";",
    ]

    public init(filename: String, source: String) {
        self.filename = filename
        self.source = source

        self.index = self.source.unicodeScalars.startIndex
        self.loc = Location(line: 1, column: 1)
    }

    private func advance() -> Unicode.Scalar? {
        guard let ch = self.restChars.first else {
            return nil
        }

        self.index = self.source.unicodeScalars.index(after: self.index)
        self.loc.column += 1

        if CharacterSet.newlines.contains(ch) {
            self.loc.line += 1
            self.loc.column = 1
        }

        return ch
    }

    private func skipChars(count: Int) {
        for _ in 1 ... count {
            _ = self.advance()
        }
    }

    // Identifier.
    private func readIdentifier(startLoc: Location) throws -> Token {
        var text = String()

        while let ch = self.restChars.first, ch.isIdentifierContinuation {
            self.advance()!.write(to: &text)
        }

        let kind: Token.Kind = Lexer.keywords.contains(text) ? .Symbol(text) : .Identifier(text)

        return Token(kind: kind, text: text, location: startLoc)
    }

    // Integer literal.
    private func readIntegerLiteral(startLoc: Location) throws -> Token {
        var text = String()

        while let ch = self.restChars.first, ch.isDigit {
            self.advance()!.write(to: &text)
        }

        guard let value = Int(text) else {
            throw LexicalError.TooLargeIntegerConstant(text: text, filename: self.filename, at: startLoc)
        }

        return Token(kind: .IntegerLiteral(value), text: text, location: startLoc)
    }

    public func read() throws -> Token {
        while let ch = self.restChars.first {
            let startLoc = self.loc

            // Whitespace.
            if CharacterSet.whitespacesAndNewlines.contains(ch) {
                _ = self.advance()
                continue
            }

            // Identifier.
            if ch.isIdentifierStart {
                return try self.readIdentifier(startLoc: startLoc)
            }

            // Integer literal.
            if ch.isDigit {
                return try self.readIntegerLiteral(startLoc: startLoc)
            }

            // Punctuator.
            for punct in Lexer.punctuators {
                if self.restChars.starts(with: punct.unicodeScalars) {
                    self.skipChars(count: punct.unicodeScalars.count)

                    return Token(kind: .Symbol(punct), text: punct, location: startLoc)
                }
            }

            // Unexpected character.
            _ = self.advance()
            throw LexicalError.UnexpectedCharacter(character: ch, filename: self.filename, at: startLoc)
        }

        // End of file.
        return Token(kind: .EndOfFile, text: "", location: self.loc)
    }
}
