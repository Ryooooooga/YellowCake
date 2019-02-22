enum SyntaxError: Error {
    case UnexpectedToken(token: Token, filename: String)
}
