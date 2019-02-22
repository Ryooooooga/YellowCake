import Foundation

public class Lexer {
    public let filename: String
    public let source: String

    private var index: String.UnicodeScalarView.Index
    private var loc: Location

    private var currentChar: Unicode.Scalar? {
        return self.index < self.source.unicodeScalars.endIndex
            ? self.source.unicodeScalars[self.index] : nil
    }

    public init(filename: String, source: String) {
        self.filename = filename
        self.source = source

        self.index = self.source.unicodeScalars.startIndex
        self.loc = Location(line: 1, column: 1)
    }

    private func advance() -> Unicode.Scalar? {
        guard let ch = self.currentChar else {
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

    // Integer literal.
    private func readIntegerLiteral(startLoc: Location) throws -> Token {
        var text = String()

        while let ch = self.currentChar, CharacterSet.decimalDigits.contains(ch) {
            self.advance()!.write(to: &text)
        }

        guard let value = Int(text) else {
            throw LexicalError.TooLargeIntegerConstant(text: text, at: startLoc)
        }

        return Token(kind: .IntegerLiteral(value: value), text: text, location: startLoc)
    }

    public func read() throws -> Token {
        while let ch = self.currentChar {
            let startLoc = self.loc

            // Integer literal.
            if CharacterSet.decimalDigits.contains(ch) {
                return try self.readIntegerLiteral(startLoc: startLoc)
            }

            // Unexpected character.
            _ = self.advance()
            throw LexicalError.UnexpectedCharacter(character: ch, at: startLoc)
        }

        // End of file.
        return Token(kind: .EndOfFile, text: "", location: self.loc)
    }
}
