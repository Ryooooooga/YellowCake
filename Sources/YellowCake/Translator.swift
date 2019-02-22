public func translateExpr(instructions: inout [IL.Instruction], expression: Expression) {
    switch expression.kind {
    case let .Integer(value):
        instructions.append(.PushInt(value))

    case let .Add(left, right):
        translateExpr(instructions: &instructions, expression: left)
        translateExpr(instructions: &instructions, expression: right)

        instructions.append(.Add)
    }
}

public func translate(expression: Expression) -> [IL.Instruction] {
    var instructions = [IL.Instruction]()

    translateExpr(instructions: &instructions, expression: expression)

    return instructions
}
