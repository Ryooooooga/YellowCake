public func translate(expression: Expression, instructions: inout [IL.Instruction]) {
    switch expression.kind {
    case let .Integer(value):
        instructions.append(.PushInt(value))

    case let .Add(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Add)

    case let .Subtract(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Sub)

    case let .Multiply(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Mul)

    case let .Divide(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Div)
    }
}

public func translate(node: Expression) -> [IL.Instruction] {
    var instructions = [IL.Instruction]()

    translate(expression: node, instructions: &instructions)

    instructions.append(.Return)

    return instructions
}
