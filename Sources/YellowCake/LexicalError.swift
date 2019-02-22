public enum LexicalError: Error {
    case UnexpectedCharacter(character: Unicode.Scalar, filename: String, at: Location)
    case TooLargeIntegerConstant(text: String, filename: String, at: Location)
}
