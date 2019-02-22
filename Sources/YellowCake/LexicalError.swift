public enum LexicalError: Error {
    case UnexpectedCharacter(character: Unicode.Scalar, at: Location)
    case TooLargeIntegerConstant(text: String, at: Location)
}
