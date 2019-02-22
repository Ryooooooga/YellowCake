import Foundation

public class Lexer {
    public let filename: String
    public let source: String

    private var index: String.UnicodeScalarView.Index
    private var loc: Location

    private var restChars: Substring.UnicodeScalarView {
        return self.source.unicodeScalars[self.index ..< self.source.unicodeScalars.endIndex]
    }

    private static let punctuators: [String] = [
        "+",
        "-",
        "*",
        "/",
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

    // Integer literal.
    private func readIntegerLiteral(startLoc: Location) throws -> Token {
        var text = String()

        while let ch = self.restChars.first, CharacterSet.decimalDigits.contains(ch) {
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

            // Integer literal.
            if CharacterSet.decimalDigits.contains(ch) {
                return try self.readIntegerLiteral(startLoc: startLoc)
            }

            // Punctuator.
            for punctuator in Lexer.punctuators {
                if self.restChars.starts(with: punctuator.unicodeScalars) {
                    self.skipChars(count: punctuator.unicodeScalars.count)

                    return Token(kind: .Punctuator, text: punctuator, location: startLoc)
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
